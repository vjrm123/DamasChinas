defmodule DamasChinas.Reglas do
  @moduledoc """
  Reglas de Damas Chinas — POR PROGRAMAR.

  Aquí irán las reglas del juego (usando `DamasChinas.Board`):

    * Movimiento simple: una ficha avanza a una casilla vecina vacía.
    * Salto: una ficha salta sobre otra (propia o rival) que esté al lado,
      cayendo en la casilla vacía de atrás.
    * Saltos en cadena: después de un salto puede seguir saltando en el
      mismo turno.
    * No hay capturas: las fichas saltadas se quedan donde están.
    * Victoria: gana quien llene la punta contraria con sus 10 fichas.

  Ejemplo de lo que se podría exponer:

      Reglas.movimientos_validos(tablero, casilla)
      Reglas.aplicar_movimiento(tablero, jugador_id, desde, hasta)
      Reglas.gano?(tablero, jugador)
  """
end
