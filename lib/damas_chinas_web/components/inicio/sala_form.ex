defmodule DamasChinasWeb.Inicio.SalaForm do
  @moduledoc """
  Recuadro Crear sala / Unirse a sala
  """
  use DamasChinasWeb, :html

  attr :modo, :atom, values: [:crear, :unirse], required: true
  attr :form, Phoenix.HTML.Form, required: true
  attr :colores, :list, required: true
  attr :color, :atom, default: nil
  attr :error, :string, default: nil

  def sala_form(assigns) do
    ~H"""
    <div
      id={"inicio-form-#{@modo}"}
      class={[
        vidrio(),
        "flex h-full animate-aparecer flex-col rounded-3xl px-7 py-5 movil:px-4 movil:py-4"
      ]}
    >
      <.encabezado modo={@modo} />

      <div class="grid flex-1 grid-cols-2 gap-7 movil:flex movil:flex-col movil:gap-3">
        <%!-- Columna izquierda--%>
        <div class="flex flex-col gap-4 movil:gap-3">
          <.form
            for={@form}
            id="inicio-player-form"
            phx-change="actualizar_form"
            phx-submit={if(@modo == :crear, do: "crear_sala", else: "unirse_sala")}
            class="flex flex-col gap-4 movil:gap-3"
          >
            <div>
              <label for="inicio-nombre-input" class={etiqueta()}>Tu nombre</label>
              <input
                type="text"
                id="inicio-nombre-input"
                name="inicio[nombre]"
                value={@form[:nombre].value}
                placeholder="Escribe tu nombre"
                phx-keyup="change_nombre"
                autocomplete="off"
                class={[campo(), "font-semibold"]}
              />
            </div>

            <div :if={@modo == :unirse}>
              <label for="inicio-codigo-input" class={etiqueta()}>Código de sala</label>
              <input
                type="text"
                id="inicio-codigo-input"
                name="inicio[codigo]"
                value={@form[:codigo].value}
                placeholder="ABC123"
                phx-keyup="change_codigo"
                maxlength="6"
                autocomplete="off"
                class={[campo(), "font-bold tracking-[0.22em] uppercase"]}
              />
            </div>
          </.form>
        </div>

        <%!-- Columna derecha --%>
        <div class="flex flex-col">
          <.elegir_color colores={@colores} color={@color} />

          <p
            :if={@error}
            id="inicio-error"
            class="mt-3 flex items-center gap-2.5 rounded-xl border border-red-500/45 bg-red-500/20 px-4 py-2.5 text-sm font-semibold text-red-200"
          >
            <.icon name="hero-exclamation-triangle" class="size-4 shrink-0" />
            {@error}
          </p>

          <.boton_vidrio
            id="inicio-submit"
            type="submit"
            form="inicio-player-form"
            color={:verde}
            icono="hero-play-solid"
            class="mt-auto justify-center movil:mt-4"
          >
            {if @modo == :crear, do: "Crear sala", else: "Unirse al lobby"}
          </.boton_vidrio>
        </div>
      </div>
    </div>
    """
  end

  #  Partes del recuadro

  attr :modo, :atom, required: true

  defp encabezado(assigns) do
    ~H"""
    <div class="mb-4 flex items-center gap-3 movil:mb-3">
      <button
        id="inicio-volver"
        type="button"
        phx-click="volver"
        aria-label="Volver"
        class={boton_icono()}
      >
        <.icon name="hero-arrow-left" class="size-5" />
      </button>
      <div>
        <p class="text-[0.65rem] font-extrabold tracking-[0.18em] text-white/55 uppercase">
          {if @modo == :crear, do: "Nueva sala", else: "Unirse a sala"}
        </p>
        <%!-- Misma tipografía y colores que el título "Damas Chinas" de la cabecera --%>
        <h2 class="bg-linear-to-b from-white via-violet-100 to-violet-300 bg-clip-text font-titulo text-[28px] leading-tight font-bold tracking-[-0.01em] text-transparent drop-shadow-[0_2px_5px_rgba(15,8,45,0.6)] movil:text-2xl">
          {if @modo == :crear, do: "¡Crea tu sala!", else: "Entra al juego"}
        </h2>
      </div>
    </div>
    """
  end

  attr :colores, :list, required: true
  attr :color, :atom, default: nil

  defp elegir_color(assigns) do
    ~H"""
    <p class={etiqueta()}>Elige tu color</p>
    <%!-- 6 colores en una sola fila --%>
    <div class="grid grid-cols-6 gap-1.5">
      <button
        :for={color <- @colores}
        id={"inicio-color-#{color}"}
        type="button"
        phx-click="change_color"
        phx-value-color={color}
        data-color={color}
        aria-pressed={to_string(@color == color)}
        class={[
          "flex flex-col items-center gap-1 rounded-xl border py-2 transition duration-150 hover:-translate-y-0.5",
          if(@color == color,
            do:
              "border-white/75 bg-white/20 shadow-[0_0_0_2px_rgba(96,196,49,0.75),0_4px_16px_rgba(0,0,0,0.35)]",
            else: "border-white/15 bg-[#060416]/50 hover:border-white/35"
          )
        ]}
      >
        <span class={[
          "size-9 rounded-full bg-radial-[at_36%_28%] via-45% shadow-[0_4px_10px_rgba(0,0,0,0.35),inset_0_1px_2px_rgba(255,255,255,0.5)] movil:size-8",
          degradado(color)
        ]}>
        </span>
        <span class="text-[9px] font-bold text-white/75">{nombre(color)}</span>
      </button>
    </div>
    """
  end

  # Colores de cada bolita
  defp degradado(:rojo), do: "from-red-300 via-red-500 to-red-800"
  defp degradado(:azul), do: "from-blue-200 via-blue-500 to-blue-700"
  defp degradado(:verde), do: "from-limon-300 via-limon-500 to-limon-700"
  defp degradado(:amarillo), do: "from-amber-100 via-amber-500 to-amber-800"
  defp degradado(:morado), do: "from-purple-300 via-purple-600 to-purple-900"
  defp degradado(:naranja), do: "from-orange-200 via-orange-500 to-orange-800"

  defp nombre(:rojo), do: "Rojo"
  defp nombre(:azul), do: "Azul"
  defp nombre(:verde), do: "Verde"
  defp nombre(:amarillo), do: "Amarillo"
  defp nombre(:morado), do: "Morado"
  defp nombre(:naranja), do: "Naranja"
end
