defmodule DamasChinasWeb.Inicio.Cabecera do
  @moduledoc "Bloque de arriba a la izquierda: logo + titulo + frase pequenia"
  use DamasChinasWeb, :html

  def cabecera(assigns) do
    ~H"""
    <header class="relative z-30 flex h-[140px] shrink-0 animate-aparecer items-center gap-4 movil:h-[76px] movil:gap-3">
      <img
        src={~p"/images/tablero2.png"}
        alt="tablerito de damas chinas"
        class="size-[136px] drop-shadow-[0_8px_16px_rgba(0,0,0,0.55)] movil:size-[72px]"
      />
      <div>
        <%!-- Título en dos líneas: "Damas" blanco y "Chinas" lavanda-morado --%>
        <h1 class="font-titulo text-[54px] leading-[0.98] font-bold tracking-[-0.01em] drop-shadow-[0_3px_6px_rgba(15,8,45,0.65)] movil:text-[34px]">
          <span class="block bg-linear-to-b from-white to-violet-100 bg-clip-text text-transparent">
            Damas
          </span>
          <span class="block bg-linear-to-b from-violet-200 via-violet-300 to-purple-400 bg-clip-text text-transparent">
            Chinas
          </span>
        </h1>
        <p class="mt-2 flex items-center gap-2 text-[15px] font-semibold tracking-wide text-white/80 movil:mt-1 movil:text-[11px]">
          <span class="h-px w-6 bg-white/45 movil:w-3"></span>
          Juega conmigo y se feliz <span class="h-px w-6 bg-white/45 movil:w-3"></span>
        </p>
      </div>
    </header>
    """
  end
end
