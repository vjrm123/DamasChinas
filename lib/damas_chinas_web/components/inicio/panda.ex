defmodule DamasChinasWeb.Inicio.Panda do
  @moduledoc """
  Panda asomado DETRas
  """
  use DamasChinasWeb, :html

  attr :oculto_en_movil, :boolean, default: false

  def panda(assigns) do
    ~H"""
    <div
      class={[
        "pointer-events-none absolute right-[90px] bottom-[calc(100%-9px)] z-20 h-[155px] w-[280px] overflow-hidden [mask-image:linear-gradient(to_bottom,#000_88%,transparent)] movil:right-7 movil:h-[88px] movil:w-[145px]",
        @oculto_en_movil && "movil:hidden"
      ]}
      aria-hidden="true"
    >
      <img
        src={~p"/images/pandita.png"}
        alt="pandita"
        class="block h-auto w-full animate-flotar drop-shadow-[0_6px_10px_rgba(0,0,0,0.45)] motion-reduce:animate-none"
      />
    </div>
    """
  end
end
