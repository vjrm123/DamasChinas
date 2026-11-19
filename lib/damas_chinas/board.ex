defmodule DamasChinas.Board do
  @moduledoc "Geometría de la estrella y ocupación de sus 121 casillas."

  @anchos [1, 2, 3, 4, 13, 12, 11, 10, 9, 10, 11, 12, 13, 4, 3, 2, 1]
  @filas (for {ancho, y} <- Enum.with_index(@anchos) do
            for x <- (1 - ancho)..(ancho - 1)//2, do: {x, y}
          end)
  @casillas @filas |> List.flatten() |> MapSet.new()
  @opuestas %{
    rojo: :naranja,
    naranja: :rojo,
    azul: :morado,
    morado: :azul,
    amarillo: :verde,
    verde: :amarillo
  }

  def filas, do: @filas
  def casilla?(posicion), do: MapSet.member?(@casillas, posicion)

  def punta({_, y}) when y < 4, do: :rojo
  def punta({_, y}) when y > 12, do: :naranja
  def punta({x, y}) when y in 4..7 and x < -y, do: :azul
  def punta({x, y}) when y in 4..7 and x > y, do: :amarillo
  def punta({x, y}) when y in 9..12 and x < y - 16, do: :verde
  def punta({x, y}) when y in 9..12 and x > 16 - y, do: :morado
  def punta(_), do: nil

  def destino(color), do: Enum.filter(@casillas, &(punta(&1) == Map.fetch!(@opuestas, color)))

  def nuevo(jugadores) do
    por_color = Map.new(jugadores, &{&1.color, &1})

    for posicion <- @casillas,
        jugador = Map.get(por_color, punta(posicion)),
        jugador != nil,
        into: %{},
        do: {posicion, jugador}
  end
end
