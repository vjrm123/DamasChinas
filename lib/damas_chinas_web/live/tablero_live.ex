defmodule DamasChinasWeb.TableroLive do
  @moduledoc """
  Pantalla de la partida de Damas Chinas.

  Por ahora el tablero está EN CONSTRUCCIÓN: muestra los jugadores de la
  partida y permite volver al lobby. Cuando se programe el juego
  (`DamasChinas.Board` / `DamasChinas.Reglas`), aquí irán los eventos para seleccionar
  y mover fichas.
  """
  use DamasChinasWeb, :live_view

  def mount(%{"codigo" => codigo}, _session, socket) do
    case DamasChinas.Salas.obtener_sala(codigo) do
      {:ok, estado} ->
        if connected?(socket), do: DamasChinas.Salas.suscribir(codigo)

        {:ok,
         socket
         |> assign(codigo: codigo, jugador_id: nil)
         |> sync_estado(estado)}

      {:error, :sala_no_existe} ->
        {:ok,
         socket
         |> put_flash(:error, "La sala no existe.")
         |> push_navigate(to: ~p"/")}
    end
  end

  # ── Eventos ──────────────────────────────────────────────────────

  # El hook JugadorSession recupera quién soy al recargar la página
  def handle_event("restore_jugador", %{"jugador_id" => jid}, socket) do
    en_sala? = Enum.any?(socket.assigns.jugadores, &(&1.id == jid))
    {:noreply, if(en_sala?, do: assign(socket, jugador_id: jid), else: socket)}
  end

  # Termina la partida para todos y vuelven al lobby
  def handle_event("volver_lobby", _params, socket) do
    %{codigo: codigo, jugador_id: jid} = socket.assigns
    DamasChinas.GameServer.rendirse(codigo, jid)
    {:noreply, socket}
  end

  # ── Mensajes de la sala (PubSub) ─────────────────────────────────

  def handle_info({:partida_iniciada, nuevo_estado}, socket),
    do: {:noreply, sync_estado(socket, nuevo_estado)}

  def handle_info({:jugador_salio, jugador_id_saliente, nuevo_estado}, socket) do
    if socket.assigns.jugador_id == jugador_id_saliente do
      {:noreply, push_navigate(socket, to: ~p"/")}
    else
      {:noreply, sync_estado(socket, nuevo_estado)}
    end
  end

  def handle_info({:partida_rendida, _nuevo_estado}, socket),
    do: {:noreply, push_navigate(socket, to: ~p"/lobby/#{socket.assigns.codigo}")}

  def handle_info(_, socket), do: {:noreply, socket}

  # Bolita de color de cada jugador (clases completas para que Tailwind las encuentre)
  defp clase_color(:rojo), do: "bg-red-500"
  defp clase_color(:azul), do: "bg-blue-500"
  defp clase_color(:verde), do: "bg-limon-500"
  defp clase_color(:amarillo), do: "bg-amber-400"
  defp clase_color(:morado), do: "bg-purple-600"
  defp clase_color(:naranja), do: "bg-orange-500"
  defp clase_color(_), do: "bg-white/50"

  # Copia del estado del servidor a los assigns de la vista
  defp sync_estado(socket, estado) do
    assign(socket,
      fase: estado.fase,
      jugadores: estado.jugadores,
      turno_jugador: Enum.at(estado.jugadores, estado.turno_idx)
    )
  end
end
