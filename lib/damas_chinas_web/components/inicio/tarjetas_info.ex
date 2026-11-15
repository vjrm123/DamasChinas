defmodule DamasChinasWeb.Inicio.TarjetasInfo do
  @moduledoc """
  Las tres tarjetas de abajo
  """
  use DamasChinasWeb, :html
  alias DamasChinasWeb.Inicio.Mapas

  attr :mapa, :integer, required: true, doc: "indice del mapa actual"

  def tarjetas_info(assigns) do
    ~H"""
    <div class="grid h-[78px] shrink-0 animate-aparecer grid-cols-[1.45fr_1fr_1fr] gap-4 [animation-delay:180ms] movil:h-[64px] movil:grid-cols-[1.5fr_1fr_1fr] movil:gap-2">
      <.tarjeta_mapa mapa={@mapa} />
      <.tarjeta icono="hero-users" titulo="Hasta" valor="6 jugadores" />
      <.tarjeta icono="hero-sparkles" titulo="Fichas" valor="10 por jugador" />
    </div>
    """
  end

  #  Tarjeta 1

  attr :mapa, :integer, required: true

  defp tarjeta_mapa(assigns) do
    assigns = assign(assigns, actual: Mapas.obtener(assigns.mapa), total: Mapas.total())

    ~H"""
    <div class={[
      vidrio(),
      "flex items-center gap-2.5 rounded-2xl px-2 movil:gap-1 movil:rounded-xl movil:px-1"
    ]}>
      <.flechita icono="hero-chevron-left" evento="mapa_anterior" etiqueta="Mapa anterior" />

      <%!-- El id cambia con el mapa --%>
      <div
        id={"mapa-miniatura-#{@mapa}"}
        class={[
          "size-[54px] shrink-0 animate-aparecer rounded-xl bg-[url('/images/fondo.webp')] bg-cover bg-center ring-2 ring-white/40 shadow-[0_4px_12px_rgba(0,0,0,0.4)] movil:hidden",
          @actual.filtro
        ]}
      >
      </div>

      <div
        id={"mapa-nombre-#{@mapa}"}
        class="min-w-0 flex-1 animate-emerger leading-tight movil:text-center"
      >
        <p class="text-xs font-semibold text-white/60 movil:text-[10px]">Mapa actual</p>
        <p class="truncate text-[15px] font-extrabold movil:text-[11px] movil:whitespace-normal">
          {@actual.nombre}
        </p>
        <%!-- Puntitos --%>
        <div class="mt-1 flex gap-1 movil:justify-center">
          <span
            :for={i <- 0..(@total - 1)}
            class={[
              "h-1 rounded-full transition-all",
              if(i == @mapa, do: "w-4 bg-limon-300", else: "w-1 bg-white/35")
            ]}
          >
          </span>
        </div>
      </div>

      <.flechita icono="hero-chevron-right" evento="mapa_siguiente" etiqueta="Mapa siguiente" />
    </div>
    """
  end

  attr :icono, :string, required: true
  attr :evento, :string, required: true
  attr :etiqueta, :string, required: true

  defp flechita(assigns) do
    ~H"""
    <button
      type="button"
      phx-click={@evento}
      aria-label={@etiqueta}
      class="grid h-[54px] w-7 shrink-0 place-items-center rounded-lg border border-white/20 bg-white/10 transition hover:bg-white/25 active:scale-95 movil:h-10 movil:w-5"
    >
      <.icon name={@icono} class="size-4" />
    </button>
    """
  end

  # ── Tarjetas 2 y 3: dato simple ────────────────────────────────

  attr :icono, :string, required: true
  attr :titulo, :string, required: true
  attr :valor, :string, required: true

  defp tarjeta(assigns) do
    ~H"""
    <div class={[
      vidrio(),
      "flex items-center gap-3 rounded-2xl px-4 movil:flex-col movil:justify-center movil:gap-0.5 movil:rounded-xl movil:px-1.5 movil:text-center"
    ]}>
      <span class="grid size-11 shrink-0 place-items-center rounded-xl bg-white/12 movil:hidden">
        <.icon name={@icono} class="size-6" />
      </span>
      <div class="leading-tight">
        <p class="text-xs font-semibold text-white/60 movil:text-[10px]">{@titulo}</p>
        <p class="text-[15px] font-extrabold movil:text-[11px]">{@valor}</p>
      </div>
    </div>
    """
  end
end
