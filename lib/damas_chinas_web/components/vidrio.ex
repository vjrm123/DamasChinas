defmodule DamasChinasWeb.Vidrio do
  @moduledoc """
  Estilo vidrio
  """
  use Phoenix.Component
  import DamasChinasWeb.CoreComponents, only: [icon: 1]


  def vidrio(oscurecer_fondo \\ true) do
    [
      "border border-white/25 bg-radial-[ellipse_75%_70%_at_50%_50%] from-[#08061a]/70 via-[#151135]/55 via-60% to-[#5b5190]/35 backdrop-blur-[4px] backdrop-saturate-125 shadow-[0_24px_55px_rgba(5,3,22,0.55),inset_0_1px_0_rgba(255,255,255,0.28),inset_0_0_36px_rgba(200,190,255,0.10)]",
      oscurecer_fondo && "backdrop-brightness-35"
    ]
  end


  @colores %{

    verde:
      "border-limon-300/60 from-limon-500/95 via-limon-500/60 to-limon-700/25 shadow-[0_8px_24px_rgba(96,196,49,0.4),inset_0_1px_0_rgba(255,255,255,0.45),inset_0_0_18px_rgba(255,255,255,0.10)]",
    celeste:
      "border-celeste-300/60 from-celeste-500/95 via-celeste-500/60 to-celeste-800/25 shadow-[0_8px_24px_rgba(35,140,219,0.4),inset_0_1px_0_rgba(255,255,255,0.45),inset_0_0_18px_rgba(255,255,255,0.10)]",
    violeta:
      "border-violet-200/50 from-violet-400/95 via-violet-500/60 to-violet-900/25 shadow-[0_8px_24px_rgba(139,92,246,0.35),inset_0_1px_0_rgba(255,255,255,0.45),inset_0_0_18px_rgba(255,255,255,0.10)]",
    oscuro:
      "border-white/20 from-white/12 via-[#14102c]/60 to-[#060414]/75 shadow-[0_4px_12px_rgba(0,0,0,0.3),inset_0_1px_0_rgba(255,255,255,0.15)]"
  }

  # Tamanios / formas
  @tamanos %{
    grande: "w-full gap-3.5 rounded-2xl px-[1.1rem] py-3 text-lg",
    chico: "gap-2 justify-center rounded-xl px-4 py-2.5 text-sm",
    pastilla: "gap-2 justify-center rounded-full px-7 py-3.5 text-lg"
  }

  # Lo que comparten todos los botones
  @base "flex items-center border bg-radial font-extrabold text-white backdrop-blur-md text-shadow-[0_1px_2px_rgba(0,0,0,0.35)] transition duration-150 enabled:hover:-translate-y-0.5 enabled:hover:brightness-115 enabled:active:scale-[0.98] disabled:cursor-not-allowed disabled:opacity-60"


  attr :color, :atom, values: [:verde, :violeta, :celeste, :oscuro], default: :oscuro
  attr :tamano, :atom, values: [:grande, :chico, :pastilla], default: :grande
  attr :icono, :string, default: nil
  attr :flecha, :boolean, default: false
  attr :type, :string, default: "button"
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(disabled form)
  slot :inner_block, required: true

  def boton_vidrio(assigns) do
    assigns =
      assign(assigns, clases: [@base, Map.fetch!(@tamanos, assigns.tamano), Map.fetch!(@colores, assigns.color)])

    ~H"""
    <button type={@type} class={[@clases, @class]} {@rest}>
      <span
        :if={@icono}
        class="grid size-9 shrink-0 place-items-center rounded-xl bg-white/20 shadow-[inset_0_1px_0_rgba(255,255,255,0.35)]"
      >
        <.icon name={@icono} class="size-5" />
      </span>
      {render_slot(@inner_block)}
      <.icon :if={@flecha} name="hero-chevron-right" class="ml-auto size-5 opacity-85" />
    </button>
    """
  end


  @doc "Input de texto oscuro'"
  def campo do
    "w-full rounded-xl border border-white/20 bg-[#060416]/55 px-4 py-3 text-sm text-white outline-none transition placeholder:text-white/35 focus:border-white/50 focus:ring-3 focus:ring-white/12"
  end

  @doc "etiqueta pequenia en mayusculas encima de un input"
  def etiqueta do
    "mb-1.5 block text-[0.68rem] font-extrabold tracking-[0.14em] text-white/55 uppercase"
  end

  @doc "Boton cuadrado pequeño -> flecha."
  def boton_icono do
    "grid size-10 shrink-0 place-items-center rounded-xl bg-white/10 transition hover:bg-white/20"
  end
end
