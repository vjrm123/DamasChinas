defmodule DamasChinas.EstadoTest do
  use ExUnit.Case, async: true

  alias DamasChinas.Estado

  defp estado_con(n_jugadores, turno_idx) do
    jugadores = for i <- 1..n_jugadores, do: %{id: "j#{i}", nombre: "J#{i}", color: :rojo}
    %Estado{codigo: "ABC123", host_id: "j1", jugadores: jugadores, turno_idx: turno_idx}
  end

  test "pasar_turno avanza al siguiente jugador" do
    assert Estado.pasar_turno(estado_con(3, 0)).turno_idx == 1
  end

  test "pasar_turno vuelve al primero después del último" do
    assert Estado.pasar_turno(estado_con(3, 2)).turno_idx == 0
  end

  test "pasar_turno sin jugadores no cambia nada" do
    estado = %Estado{codigo: "ABC123", host_id: "j1"}
    assert Estado.pasar_turno(estado) == estado
  end
end
