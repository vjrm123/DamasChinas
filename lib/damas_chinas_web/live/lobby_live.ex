# lib/damas_chinas_web/live/lobby_live.ex
defmodule DamasChinasWeb.LobbyLive do
  use DamasChinasWeb, :live_view

  alias DamasChinas.Salas
  alias DamasChinasWeb.JugadorSession

  def mount(%{"codigo" => codigo}, _session, socket) do
    if connected?(socket), do: Salas.suscribir(codigo)

    case Salas.obtener_sala(codigo) do
      {:ok, %{fase: fase, codigo: codigo}} when fase in [:jugando, :finalizada] ->
        {:ok, push_navigate(socket, to: ~p"/tablero/#{codigo}")}

      {:ok, estado} ->
        {:ok,
         assign(socket,
           codigo: estado.codigo,
           jugador_id: nil,
           estado: estado,
           color_hex: DamasChinas.Colores.mapa_hex()
         )}

      {:error, :sala_no_existe} ->
        {:ok,
         socket
         |> put_flash(:error, "La sala #{codigo} no existe.")
         |> push_navigate(to: ~p"/")}
    end
  end

  def handle_event("iniciar_partida", _params, socket) do
    %{codigo: codigo, jugador_id: jugador_id} = socket.assigns

    case Salas.iniciar_partida(codigo, jugador_id) do
      {:ok, _estado} ->
        {:noreply, socket}

      {:error, razon} ->
        {:noreply, put_flash(socket, :error, "No se puede iniciar: #{razon}")}
    end
  end

  def handle_event("restore_jugador", %{"token" => token}, socket) when is_binary(token) do
    %{codigo: codigo, estado: estado} = socket.assigns

    with {:ok, jugador_id} <- JugadorSession.verificar(token, codigo),
         true <- Enum.any?(estado.jugadores, &(&1.id == jugador_id)) do
      {:noreply, assign(socket, jugador_id: jugador_id)}
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("restore_jugador", _, socket), do: {:noreply, socket}

  def handle_event("salir_sala", _params, socket) do
    %{codigo: codigo, jugador_id: jugador_id} = socket.assigns
    Salas.salir_sala(codigo, jugador_id)
    {:noreply, push_navigate(socket, to: ~p"/")}
  end

  def handle_info({:jugador_unido, nuevo_estado}, socket) do
    {:noreply, assign(socket, estado: nuevo_estado)}
  end

  def handle_info({:jugador_salio, jugador_id_saliente, nuevo_estado}, socket) do
    socket =
      if socket.assigns.jugador_id == jugador_id_saliente do
        push_navigate(socket, to: ~p"/")
      else
        assign(socket, estado: nuevo_estado)
      end

    {:noreply, socket}
  end

  def handle_info({:partida_iniciada, _estado}, socket) do
    # Todos navegan al tablero cuando el host inicia
    {:noreply, push_navigate(socket, to: ~p"/tablero/#{socket.assigns.codigo}")}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  def es_host?(estado, jugador_id),
    do: estado.host_id == jugador_id

  def puede_iniciar?(estado),
    do: length(estado.jugadores) >= 2 && estado.fase == :esperando

  def render_jugador_card(jugador, host_id, color_hex) do
    assigns = %{jugador: jugador, host_id: host_id, color_hex: color_hex}

    ~H"""
    <div
      id={"lobby-jugador-#{@jugador.id}"}
      class="rounded-2xl px-5 py-4 transition-all duration-200"
      style="background: rgba(255,255,255,0.22); border: 1px solid rgba(255,255,255,0.35);"
    >
      <div class="flex items-center gap-4">
        <span
          class="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl text-sm font-extrabold text-white"
          style={"background-color: #{Map.fetch!(@color_hex, @jugador.color)}; box-shadow: 0 4px 14px rgba(0,0,0,0.35);"}
        >
          {String.first(@jugador.nombre) |> String.upcase()}
        </span>
        <div class="min-w-0 flex-1">
          <div class="flex items-center gap-2">
            <p class="truncate text-base font-extrabold text-white">
              {@jugador.nombre}
            </p>
            <.icon
              :if={@jugador.id == @host_id}
              name="hero-star-solid"
              class="size-4 shrink-0 text-amber-400"
            />
          </div>
          <p class="text-sm font-semibold capitalize text-white/45">
            {Atom.to_string(@jugador.color)}
          </p>
        </div>
      </div>
    </div>
    """
  end
end
