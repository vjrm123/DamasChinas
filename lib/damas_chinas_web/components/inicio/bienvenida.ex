defmodule DamasChinasWeb.Inicio.Bienvenida do
  @moduledoc """
  Recuadro central de bienvenida
  """
  use DamasChinasWeb, :html

  def bienvenida(assigns) do
    ~H"""
    <div
      id="inicio-hero"
      class={[
        vidrio(),
        "flex h-full animate-aparecer flex-col rounded-3xl px-7 py-5 movil:px-4 movil:py-4"
      ]}
    >
      <p class="flex items-center gap-2 text-lg font-bold movil:text-base">
        <.icon name="hero-star-solid" class="size-5 text-violet-300" /> ¡Bienvenido!
      </p>

      <div class="grid min-h-0 flex-1 grid-cols-[1.35fr_1fr] items-center gap-4 movil:flex movil:flex-col movil:justify-between movil:gap-3">
        <.tablero />

        <div class="flex flex-col items-end gap-7 text-right movil:w-full movil:items-center movil:gap-4 movil:text-center">
          <div>
            <p class="text-[21px] leading-snug font-semibold text-white/85 italic movil:text-[16px]">
              Juega con tus amigos y se el primero en llegar al lado contrario con todas tus fichas.
            </p>
            <div class="mt-3 ml-auto h-0.5 w-28 rounded-full bg-linear-to-r from-transparent to-limon-300 movil:mx-auto movil:mt-2">
            </div>
          </div>

          <div class="movil:hidden">
            <.boton_vidrio
              id="inicio-empezar"
              color={:verde}
              tamano={:pastilla}
              flecha
              phx-click="modo_crear"
            >
              ¡Empezar ahora!
            </.boton_vidrio>
          </div>
          <div class="hidden w-full movil:block">
            <.boton_vidrio
              id="inicio-empezar-movil"
              color={:verde}
              tamano={:pastilla}
              flecha
              class="w-full"
              phx-click="abrir_menu"
            >
              ¡Empezar ahora!
            </.boton_vidrio>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # Tablero con halo morado detrás y una órbita brillante alrededor
  defp tablero(assigns) do
    ~H"""
    <div class="relative flex h-full min-h-0 items-center justify-center movil:h-auto">
      <div class="relative">
        <div class="pointer-events-none absolute top-[55%] left-1/2 aspect-[1.6/1] w-[120%] -translate-1/2 bg-radial from-purple-500/35 to-transparent to-65% blur-[10px]">
        </div>
        <div class="pointer-events-none absolute top-[60%] left-1/2 aspect-[2.9/1] w-[135%] -translate-1/2 rounded-full border-2 border-purple-300/80 shadow-[0_0_18px_rgba(192,132,252,0.75),0_0_46px_rgba(147,51,234,0.45),inset_0_0_22px_rgba(192,132,252,0.45)] after:absolute after:-inset-x-[22px] after:-inset-y-[14px] after:rounded-full after:border after:border-purple-300/30">
        </div>
        <img
          src={~p"/images/tablero2.png"}
          alt="Tablero con fichas de colores"
          class="relative size-[262px] animate-suave drop-shadow-[0_18px_28px_rgba(0,0,0,0.6)] motion-reduce:animate-none movil:size-[280px]"
        />
      </div>
    </div>
    """
  end
end
