# lib/damas_chinas/colores.ex
defmodule DamasChinas.Colores do
  # Fuente unica de verdad para los colores de jugador (sala/lobby/partida).
  # Son los 6 colores de las puntas del tablero de Damas Chinas.

  @lista [:rojo, :azul, :verde, :amarillo, :morado, :naranja]
  @hex %{
    rojo: "#ef4444",
    azul: "#3b82f6",
    verde: "#60c431",
    amarillo: "#f59e0b",
    morado: "#9333ea",
    naranja: "#f97316"
  }

  def lista, do: @lista
  def hex(color), do: Map.get(@hex, color)
  def mapa_hex, do: @hex
end
