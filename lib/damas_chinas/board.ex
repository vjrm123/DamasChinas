defmodule DamasChinas.Board do
  @moduledoc """
  Tablero de Damas Chinas — POR PROGRAMAR.

  Aquí irá la forma del tablero:

    * Las 121 casillas de la estrella de 6 puntas (coordenadas de cada casilla).
    * Las 6 puntas (zonas de inicio/meta) y qué color empieza en cada una.
    * La posición inicial de las 10 fichas de cada jugador.
    * Las casillas vecinas de cada casilla (6 direcciones).

  Ejemplo de lo que se podría exponer:

      Board.nuevo(jugadores)        # tablero inicial con las fichas en su punta
      Board.vecinas(casilla)        # casillas de alrededor
      Board.punta_destino(color)    # casillas que hay que llenar para ganar
  """
end
