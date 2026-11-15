defmodule DamasChinasWeb.Inicio.MenuPrincipal do
  @moduledoc """
  Menu  Crear sala, Unirse a sala, Inicio y Reglas.

  """
  use DamasChinasWeb, :html

  attr :modo, :atom, default: nil, doc: "nil, :crear o :unirse"
  attr :visible_en_movil, :boolean, default: false

  def menu_principal(assigns) do
    ~H"""
    <nav
      class={[
        vidrio(),
        "flex animate-aparecer flex-col gap-3.5 self-start rounded-3xl p-5 [animation-delay:60ms] movil:my-auto movil:self-stretch",
        !@visible_en_movil && "movil:hidden"
      ]}
      aria-label="Menú principal"
    >
      <%!-- Solo en celular --%>
      <div class="mb-1 hidden items-center gap-3 movil:flex">
        <button
          id="inicio-cerrar-menu"
          type="button"
          phx-click="cerrar_menu"
          aria-label="Volver"
          class={boton_icono()}
        >
          <.icon name="hero-arrow-left" class="size-5" />
        </button>
        <h2 class="font-display text-2xl font-extrabold">¿Como quieres jugar?</h2>
      </div>

      <.boton_vidrio
        id="inicio-modo-crear"
        color={:verde}
        icono="hero-plus"
        flecha
        phx-click="modo_crear"
      >
        Crear sala
      </.boton_vidrio>

      <.boton_vidrio
        id="inicio-modo-unirse"
        color={:celeste}
        icono="hero-user-group"
        flecha
        phx-click="modo_unirse"
      >
        Unirse a sala
      </.boton_vidrio>

      <div class="my-2 h-px bg-white/12"></div>

      <.boton_vidrio :if={@modo} id="inicio-volver-menu" icono="hero-home" flecha phx-click="volver">
        Inicio
      </.boton_vidrio>

      <.boton_vidrio id="inicio-reglas" icono="hero-book-open" flecha phx-click="abrir_ayuda">
        Reglas del juego
      </.boton_vidrio>
    </nav>
    """
  end
end
