# lib/damas_chinas_web/live/inicio_live.ex
defmodule DamasChinasWeb.InicioLive do
  use DamasChinasWeb, :live_view

  # Bloques de la pantalla (cada uno en lib/damas_chinas_web/components/inicio/)
  import DamasChinasWeb.Inicio.Cabecera
  import DamasChinasWeb.Inicio.MenuPrincipal
  import DamasChinasWeb.Inicio.Panda
  import DamasChinasWeb.Inicio.Bienvenida
  import DamasChinasWeb.Inicio.SalaForm
  import DamasChinasWeb.Inicio.TarjetasInfo
  import DamasChinasWeb.Inicio.Ayuda
  alias DamasChinasWeb.Inicio.Mapas

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        modo: nil,
        ayuda: false,
        # Solo en celular: true = se muestra el menú (crear/unirse) en vez de la bienvenida
        menu_movil: false,
        # Índice del mapa (fondo) elegido, ver DamasChinasWeb.Inicio.Mapas
        mapa: 0,
        nombre: "",
        color: nil,
        codigo_entrada: "",
        error: nil,
        colores: DamasChinas.Colores.lista(),
        color_hex: DamasChinas.Colores.mapa_hex()
      )
      |> assign_inicio_form()

    {:ok, socket}
  end

  def handle_event("modo_crear", _params, socket),
    do: {:noreply, assign(socket, modo: :crear, error: nil)}

  def handle_event("modo_unirse", _params, socket),
    do: {:noreply, assign(socket, modo: :unirse, error: nil)}

  def handle_event("volver", _params, socket),
    do: {:noreply, assign(socket, modo: nil, error: nil)}

  def handle_event("abrir_menu", _params, socket),
    do: {:noreply, assign(socket, menu_movil: true, error: nil)}

  def handle_event("cerrar_menu", _params, socket),
    do: {:noreply, assign(socket, menu_movil: false, modo: nil, error: nil)}

  def handle_event("mapa_siguiente", _params, socket),
    do: {:noreply, update(socket, :mapa, &Mapas.siguiente/1)}

  def handle_event("mapa_anterior", _params, socket),
    do: {:noreply, update(socket, :mapa, &Mapas.anterior/1)}

  def handle_event("abrir_ayuda", _params, socket),
    do: {:noreply, assign(socket, ayuda: true)}

  def handle_event("cerrar_ayuda", _params, socket),
    do: {:noreply, assign(socket, ayuda: false)}

  def handle_event("change_nombre", %{"value" => val}, socket) do
    {:noreply,
     socket
     |> assign(nombre: val, error: nil)
     |> assign_inicio_form()}
  end

  def handle_event("change_codigo", %{"value" => val}, socket) do
    {:noreply,
     socket
     |> assign(codigo_entrada: String.upcase(val), error: nil)
     |> assign_inicio_form()}
  end

  def handle_event("change_color", %{"color" => color}, socket) do
    color_atom = Enum.find(DamasChinas.Colores.lista(), &(Atom.to_string(&1) == color))

    if color_atom do
      {:noreply, assign(socket, color: color_atom, error: nil)}
    else
      {:noreply, assign(socket, error: traducir_error(:color_invalido))}
    end
  end

  def handle_event("actualizar_form", params, socket) do
    {:noreply,
     socket
     |> assign_form_params(params)
     |> assign(error: nil)
     |> assign_inicio_form()}
  end

  def handle_event("crear_sala", params, socket) do
    socket =
      socket
      |> assign_form_params(params)
      |> assign_inicio_form()

    case DamasChinas.Salas.crear_sala(socket.assigns.nombre, socket.assigns.color) do
      {:ok, %{codigo: codigo, host_id: host_id}} ->
        {:noreply,
         socket
         |> push_event("set_jugador_id", %{jugador_id: host_id, codigo: codigo})
         |> push_navigate(to: ~p"/lobby/#{codigo}")}

      {:error, razon} ->
        {:noreply, assign(socket, error: traducir_error(razon))}
    end
  end

  def handle_event("unirse_sala", params, socket) do
    socket =
      socket
      |> assign_form_params(params)
      |> assign_inicio_form()

    %{codigo_entrada: codigo, nombre: nombre, color: color} = socket.assigns

    case DamasChinas.Salas.unirse_sala(codigo, nombre, color) do
      {:ok, %{jugador_id: jugador_id}} ->
        {:noreply,
         socket
         |> push_event("set_jugador_id", %{jugador_id: jugador_id, codigo: codigo})
         |> push_navigate(to: ~p"/lobby/#{codigo}")}

      {:error, razon} ->
        {:noreply, assign(socket, error: traducir_error(razon))}
    end
  end

  defp assign_form_params(socket, %{"inicio" => params}) do
    assign(socket,
      nombre: Map.get(params, "nombre", socket.assigns.nombre),
      codigo_entrada:
        params
        |> Map.get("codigo", socket.assigns.codigo_entrada)
        |> String.upcase()
    )
  end

  defp assign_form_params(socket, _params), do: socket

  defp assign_inicio_form(socket) do
    assign(
      socket,
      :form,
      to_form(
        %{"nombre" => socket.assigns.nombre, "codigo" => socket.assigns.codigo_entrada},
        as: :inicio
      )
    )
  end

  defp traducir_error(:sala_no_existe), do: "La sala no existe"
  defp traducir_error(:sala_llena), do: "La sala está llena (máximo 6 jugadores)"
  defp traducir_error(:color_tomado), do: "Ese color ya fue elegido por otro jugador"
  defp traducir_error(:nombre_invalido), do: "El nombre debe tener al menos 2 caracteres"
  defp traducir_error(:color_invalido), do: "Selecciona un color valido"
  defp traducir_error(_), do: "Error inesperado. Intenta de nuevo"
end
