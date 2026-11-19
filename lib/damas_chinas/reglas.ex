defmodule DamasChinas.Reglas do
  @moduledoc "Movimientos simples, cadenas de saltos sin captura y victoria."

  alias DamasChinas.Board

  @direcciones [{-2, 0}, {2, 0}, {-1, -1}, {1, -1}, {-1, 1}, {1, 1}]

  def destinos(tablero, origen) do
    # Durante la cadena la casilla de origen queda libre.
    ocupadas = Map.delete(tablero, origen)

    pasos =
      for direccion <- @direcciones,
          posicion = sumar(origen, direccion),
          libre?(tablero, posicion),
          do: posicion
    
    # Pruebas de saltos aun pendiente
    # saltos = explorar([origen], ocupadas, MapSet.new([origen]))
    # unir los saltos con lo permitido aun pendiente de pruebas
    # MapSet.union(MapSet.new(pasos), MapSet.delete(saltos, origen))
    MapSet.new(pasos)
  end

  def gano?(tablero, jugador) do
    Enum.all?(Board.destino(jugador.color), fn posicion ->
      match?(%{id: id} when id == jugador.id, Map.get(tablero, posicion))
    end)
  end

  defp explorar([], _tablero, visitadas), do: visitadas

  defp explorar([posicion | pendientes], tablero, visitadas) do
    saltos =
      for direccion <- @direcciones,
          intermedia = sumar(posicion, direccion),
          destino = sumar(intermedia, direccion),
          Map.has_key?(tablero, intermedia),
          libre?(tablero, destino),
          not MapSet.member?(visitadas, destino),
          do: destino

    explorar(saltos ++ pendientes, tablero, Enum.into(saltos, visitadas))
  end

  defp libre?(tablero, posicion),
    do: Board.casilla?(posicion) and not Map.has_key?(tablero, posicion)

  defp sumar({x, y}, {dx, dy}), do: {x + dx, y + dy}
end
