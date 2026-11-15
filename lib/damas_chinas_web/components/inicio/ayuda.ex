defmodule DamasChinasWeb.Inicio.Ayuda do
  @moduledoc """
  reglas del juego
  """
  use DamasChinasWeb, :html

  @reglas [
    "primera regla",
    "segunda regla",
    "tercera regla y asi hasta terminar",
  ]

  def ayuda(assigns) do
    assigns = assign(assigns, :reglas, Enum.with_index(@reglas, 1))

    ~H"""
    <div
      id="inicio-ayuda"
      class="fixed inset-0 z-50 grid place-items-center bg-black/65 p-4"
      phx-window-keydown="cerrar_ayuda"
      phx-key="Escape"
    >
      <div
        class={[
          vidrio(false),"max-h-[92vh] w-full max-w-lg animate-emerger overflow-y-auto rounded-3xl p-6"]}
        role="dialog"
        aria-modal="true"
        aria-labelledby="inicio-ayuda-titulo"
        phx-click-away="cerrar_ayuda"
      >
        <div class="mb-4 flex items-center justify-between gap-4">
          <h2 id="inicio-ayuda-titulo" class="font-display text-2xl font-extrabold">Cómo jugar</h2>
          <button type="button" phx-click="cerrar_ayuda" aria-label="Cerrar" class={boton_icono()}>
            <.icon name="hero-x-mark" class="size-5" />
          </button>
        </div>

        <ol class="space-y-3 text-sm leading-relaxed text-white/85">
          <li :for={{texto, n} <- @reglas} class="flex gap-3">
            <span class="grid size-6 shrink-0 place-items-center rounded-full bg-limon-500 text-xs font-extrabold">
              {n}
            </span>
            <span>{texto}</span>
          </li>
        </ol>
      </div>
    </div>
    """
  end
end
