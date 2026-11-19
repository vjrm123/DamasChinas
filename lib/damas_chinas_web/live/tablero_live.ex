defmodule DamasChinasWeb.TableroLive do
  @moduledoc "Tablero sincronizado y selección de jugadas."

  use DamasChinasWeb, :live_view

  alias DamasChinas.{Board, Colores, GameServer, Reglas, Salas}
  alias DamasChinasWeb.JugadorSession

  def mount(%{"codigo" => codigo}, _session, socket) do
    if connected?(socket), do: Salas.suscribir(codigo)

    case Salas.obtener_sala(codigo) do
      {:ok, %{fase: :esperando, codigo: codigo}} ->
        {:ok, push_navigate(socket, to: ~p"/lobby/#{codigo}")}

      {:ok, estado} ->
        {:ok,
         socket
         |> assign(codigo: estado.codigo, jugador_id: nil, filas: Board.filas())
         |> sync_estado(estado)}

      {:error, :sala_no_existe} ->
        {:ok,
         socket
         |> put_flash(:error, "La sala no existe.")
         |> push_navigate(to: ~p"/")}
    end
  end

  def handle_event("restore_jugador", %{"token" => token}, socket) when is_binary(token) do
    %{codigo: codigo, jugadores: jugadores} = socket.assigns

    with {:ok, jugador_id} <- JugadorSession.verificar(token, codigo),
         true <- Enum.any?(jugadores, &(&1.id == jugador_id)) do
      {:noreply, assign(socket, jugador_id: jugador_id)}
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("restore_jugador", _, socket), do: {:noreply, socket}

  def handle_event("casilla", %{"x" => x, "y" => y}, socket)
      when is_binary(x) and is_binary(y) do
    with %{id: jugador_id} <- socket.assigns.turno_jugador,
         true <- socket.assigns.fase == :jugando and jugador_id == socket.assigns.jugador_id,
         {x, ""} <- Integer.parse(x),
         {y, ""} <- Integer.parse(y),
         true <- Board.casilla?({x, y}) do
      {:noreply, seleccionar(socket, {x, y}, jugador_id)}
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("casilla", _, socket), do: {:noreply, socket}

  def handle_event("volver_lobby", _params, socket) do
    %{codigo: codigo, jugador_id: jugador_id} = socket.assigns

    case GameServer.rendirse(codigo, jugador_id) do
      {:ok, _} -> {:noreply, socket}
      {:error, _} -> {:noreply, put_flash(socket, :error, "No se pudo cerrar la partida.")}
    end
  end

  def handle_info({evento, estado}, socket)
      when evento in [:partida_iniciada, :tablero_actualizado],
      do: {:noreply, sync_estado(socket, estado)}

  def handle_info({:jugador_salio, jugador_id, estado}, socket) do
    if socket.assigns.jugador_id == jugador_id do
      {:noreply, push_navigate(socket, to: ~p"/")}
    else
      {:noreply, sync_estado(socket, estado)}
    end
  end

  def handle_info({:partida_rendida, _estado}, socket),
    do: {:noreply, push_navigate(socket, to: ~p"/lobby/#{socket.assigns.codigo}")}

  def handle_info(_, socket), do: {:noreply, socket}

  defp seleccionar(socket, posicion, jugador_id) do
    %{seleccion: seleccion, destinos: destinos, tablero: tablero, codigo: codigo} = socket.assigns

    cond do
      seleccion == posicion ->
        assign(socket, seleccion: nil, destinos: MapSet.new())

      MapSet.member?(destinos, posicion) ->
        case GameServer.mover(codigo, jugador_id, seleccion, posicion) do
          {:ok, _} -> assign(socket, seleccion: nil, destinos: MapSet.new())
          {:error, _} -> put_flash(socket, :error, "La jugada ya no está disponible.")
        end

      match?(%{id: ^jugador_id}, Map.get(tablero, posicion)) ->
        assign(socket, seleccion: posicion, destinos: Reglas.destinos(tablero, posicion))

      true ->
        socket
    end
  end

  defp sync_estado(socket, estado) do
    assign(socket,
      fase: estado.fase,
      jugadores: estado.jugadores,
      tablero: estado.tablero,
      ganador: Enum.find(estado.jugadores, &(&1.id == estado.ganador_id)),
      turno_jugador: Enum.at(estado.jugadores, estado.turno_idx),
      seleccion: nil,
      destinos: MapSet.new()
    )
  end

  defp estilo_casilla({x, y}, ficha, punta) do
    color = if ficha, do: Colores.hex(ficha.color), else: Colores.hex(punta) || "#9f7145"
    "--casilla-x: #{50 + x * 3.58}%; --casilla-y: #{6 + y * 5.5}%; --casilla-color: #{color};"
  end

  defp etiqueta_casilla(ficha, destino?, x, y) do
    contenido =
      cond do
        ficha -> "Ficha #{ficha.color} de #{ficha.nombre}"
        destino? -> "Destino disponible"
        true -> "Casilla vacía"
      end

    "#{contenido}, fila #{y + 1}, posición #{x + 13}"
  end
end
