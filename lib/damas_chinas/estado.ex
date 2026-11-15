defmodule DamasChinas.Estado do
  @moduledoc """
  Estado de una sala de Damas Chinas (lo guarda `DamasChinas.GameServer`).

  Por ahora solo maneja la sala: jugadores, fase y turno.
  El campo `tablero` queda listo para cuando se programe el juego
  (ver `DamasChinas.Board` y `DamasChinas.Reglas`).
  """
  @enforce_keys [:codigo, :host_id]
  defstruct [
    :codigo,
    :host_id,
    # [%{id, nombre, color}]
    jugadores: [],
    modo: :clasico,
    # :esperando | :jugando | :finalizada
    fase: :esperando,
    # posición (en la lista de jugadores) de quien tiene el turno
    turno_idx: 0,
    # posiciones de las fichas: se llenará con DamasChinas.Board
    tablero: %{}
  ]

  @doc "Pasa el turno al siguiente jugador."
  def pasar_turno(%__MODULE__{jugadores: []} = estado), do: estado

  def pasar_turno(%__MODULE__{} = estado) do
    %{estado | turno_idx: rem(estado.turno_idx + 1, length(estado.jugadores))}
  end
end
