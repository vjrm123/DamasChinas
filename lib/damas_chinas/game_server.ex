defmodule DamasChinas.GameServer do
  @moduledoc "Un proceso por sala que valida jugadas y publica el estado de la partida."
  use GenServer, restart: :transient
  require Logger

  alias DamasChinas.{Board, Estado, Reglas}

  # Damas Chinas: una punta de la estrella por jugador
  @max_jugadores 6
  @timeout_sala :timer.minutes(60)

  # ── API pública ──────────────────────────────────────────────────

  def start_link(opts) do
    codigo = Keyword.fetch!(opts, :codigo)
    GenServer.start_link(__MODULE__, opts, name: via(codigo), timeout: @timeout_sala)
  end

  def get_estado(codigo), do: GenServer.call(via(codigo), :get_estado)
  def unirse(codigo, jugador), do: GenServer.call(via(codigo), {:unirse, jugador})
  def salir(codigo, jugador_id), do: GenServer.cast(via(codigo), {:salir, jugador_id})
  def iniciar(codigo, host_id), do: GenServer.call(via(codigo), {:iniciar, host_id})

  def mover(codigo, jugador_id, desde, hasta),
    do: GenServer.call(via(codigo), {:mover, jugador_id, desde, hasta})

  @doc "Termina la partida y todos vuelven al lobby."
  def rendirse(codigo, jugador_id), do: GenServer.call(via(codigo), {:rendirse, jugador_id})

  # ── Callbacks ────────────────────────────────────────────────────

  @impl true
  def init(opts) do
    codigo = Keyword.fetch!(opts, :codigo)
    host_id = Keyword.fetch!(opts, :host_id)
    modo = Keyword.get(opts, :modo, :clasico)
    Logger.info("GameServer iniciado para sala #{codigo}")
    {:ok, %Estado{codigo: codigo, host_id: host_id, modo: modo}, @timeout_sala}
  end

  @impl true
  def handle_call(:get_estado, _from, estado) do
    {:reply, {:ok, estado}, estado, @timeout_sala}
  end

  @impl true
  def handle_call({:unirse, jugador}, _from, estado) do
    cond do
      estado.fase != :esperando ->
        {:reply, {:error, :ya_iniciada}, estado, @timeout_sala}

      length(estado.jugadores) >= @max_jugadores ->
        {:reply, {:error, :sala_llena}, estado, @timeout_sala}

      color_tomado?(estado.jugadores, jugador.color) ->
        {:reply, {:error, :color_tomado}, estado, @timeout_sala}

      jugador_ya_existe?(estado.jugadores, jugador.id) ->
        {:reply, {:error, :ya_en_sala}, estado, @timeout_sala}

      true ->
        nuevo_estado = %{estado | jugadores: estado.jugadores ++ [jugador]}
        broadcast!(nuevo_estado.codigo, {:jugador_unido, nuevo_estado})
        {:reply, {:ok, nuevo_estado}, nuevo_estado, @timeout_sala}
    end
  end

  @impl true
  def handle_call({:iniciar, host_id}, _from, estado) do
    cond do
      estado.host_id != host_id ->
        {:reply, {:error, :no_es_host}, estado, @timeout_sala}

      length(estado.jugadores) < 2 ->
        {:reply, {:error, :pocos_jugadores}, estado, @timeout_sala}

      estado.fase != :esperando ->
        {:reply, {:error, :ya_iniciada}, estado, @timeout_sala}

      true ->
        nuevo = %{estado | fase: :jugando, tablero: Board.nuevo(estado.jugadores), turno_idx: 0}
        broadcast!(nuevo.codigo, {:partida_iniciada, nuevo})
        {:reply, {:ok, nuevo}, nuevo, @timeout_sala}
    end
  end

  @impl true
  def handle_call({:mover, jugador_id, desde, hasta}, _from, estado) do
    jugador = Enum.at(estado.jugadores, estado.turno_idx)

    with :jugando <- estado.fase,
         %{id: ^jugador_id} <- jugador,
         %{id: ^jugador_id} <- Map.get(estado.tablero, desde),
         true <- MapSet.member?(Reglas.destinos(estado.tablero, desde), hasta) do
      tablero = estado.tablero |> Map.delete(desde) |> Map.put(hasta, jugador)
      nuevo = %{estado | tablero: tablero}

      nuevo =
        if Reglas.gano?(tablero, jugador),
          do: %{nuevo | fase: :finalizada, ganador_id: jugador_id},
          else: Estado.pasar_turno(nuevo)

      broadcast!(nuevo.codigo, {:tablero_actualizado, nuevo})
      {:reply, {:ok, nuevo}, nuevo, @timeout_sala}
    else
      _ -> {:reply, {:error, :movimiento_invalido}, estado, @timeout_sala}
    end
  end

  @impl true
  def handle_call({:rendirse, jugador_id}, _from, estado) do
    cond do
      not jugador_ya_existe?(estado.jugadores, jugador_id) ->
        {:reply, {:error, :no_es_jugador}, estado, @timeout_sala}

      estado.fase == :esperando ->
        {:reply, {:error, :partida_no_activa}, estado, @timeout_sala}

      true ->
        nuevo = %{estado | fase: :esperando, tablero: %{}, turno_idx: 0, ganador_id: nil}
        broadcast!(nuevo.codigo, {:partida_rendida, nuevo})
        {:reply, {:ok, nuevo}, nuevo, @timeout_sala}
    end
  end

  @impl true
  def handle_cast({:salir, jugador_id}, estado) do
    nuevo_estado = ejecutar_salir(estado, jugador_id)

    if nuevo_estado.jugadores == [],
      do: {:stop, :normal, nuevo_estado},
      else: {:noreply, nuevo_estado, @timeout_sala}
  end

  @impl true
  def handle_info(:timeout, estado) do
    Logger.info("Sala #{estado.codigo} expirada por inactividad")
    {:stop, :normal, estado}
  end

  # ── Helpers privados ─────────────────────────────────────────────

  defp via(codigo), do: {:via, Registry, {DamasChinas.SalaRegistry, codigo}}

  defp broadcast!(codigo, msg),
    do: Phoenix.PubSub.broadcast(DamasChinas.PubSub, "sala:#{codigo}", msg)

  defp ejecutar_salir(estado, jugador_id) do
    idx_saliente = Enum.find_index(estado.jugadores, &(&1.id == jugador_id))
    jugadores = Enum.reject(estado.jugadores, &(&1.id == jugador_id))

    tablero = Map.reject(estado.tablero, fn {_posicion, ficha} -> ficha.id == jugador_id end)

    nuevo =
      %{estado | jugadores: jugadores, tablero: tablero}
      |> pasar_host(estado.host_id == jugador_id)
      |> ajustar_turno(idx_saliente)
      |> terminar_si_queda_uno()

    broadcast!(nuevo.codigo, {:jugador_salio, jugador_id, nuevo})
    nuevo
  end

  # Si se fue el anfitrión, el siguiente jugador pasa a serlo
  defp pasar_host(%{jugadores: [nuevo_host | _]} = estado, true),
    do: %{estado | host_id: nuevo_host.id}

  defp pasar_host(estado, _), do: estado

  # Si se fue alguien antes del jugador en turno, el índice se corre uno
  defp ajustar_turno(%{fase: :jugando} = estado, idx) when is_integer(idx) do
    cond do
      estado.jugadores == [] -> %{estado | turno_idx: 0}
      idx < estado.turno_idx -> %{estado | turno_idx: estado.turno_idx - 1}
      true -> %{estado | turno_idx: rem(estado.turno_idx, length(estado.jugadores))}
    end
  end

  defp ajustar_turno(estado, _), do: estado

  # Con un solo jugador la partida ya no puede seguir
  defp terminar_si_queda_uno(%{fase: :jugando, jugadores: jugadores} = estado)
       when length(jugadores) <= 1,
       do: %{estado | fase: :finalizada, turno_idx: 0}

  defp terminar_si_queda_uno(estado), do: estado

  defp color_tomado?(jugadores, color), do: Enum.any?(jugadores, &(&1.color == color))
  defp jugador_ya_existe?(jugadores, id), do: Enum.any?(jugadores, &(&1.id == id))
end
