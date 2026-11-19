defmodule DamasChinas.ReglasTest do
  use ExUnit.Case, async: true

  alias DamasChinas.{Board, Colores, Reglas}

  test "la estrella tiene 121 casillas y diez fichas por punta con seis jugadores" do
    jugadores = Enum.map(Colores.lista(), &%{id: &1, color: &1})
    casillas = List.flatten(Board.filas())
    tablero = Board.nuevo(jugadores)

    assert length(casillas) == 121
    assert length(Enum.uniq(casillas)) == 121
    assert map_size(tablero) == 60

    for jugador <- jugadores do
      assert Enum.count(tablero, fn {_, ficha} -> ficha == jugador end) == 10
      assert length(Board.destino(jugador.color)) == 10
      refute Reglas.gano?(tablero, jugador)
    end
  end

  test "permite pasos y saltos encadenados sobre fichas de cualquier jugador" do
    origen = {0, 8}
    tablero = %{origen => :propia, {2, 8} => :rival, {6, 8} => :propia}
    destinos = Reglas.destinos(tablero, origen)

    assert MapSet.member?(destinos, {-2, 8})
    assert MapSet.member?(destinos, {4, 8})
    assert MapSet.member?(destinos, {8, 8})
    refute MapSet.member?(destinos, {2, 8})
    refute MapSet.member?(destinos, {10, 8})
    refute MapSet.member?(destinos, origen)
  end

  test "solo gana quien llena por completo su punta opuesta" do
    jugador = %{id: "uno", color: :rojo}
    destino = Board.destino(:rojo)
    tablero = Map.new(destino, &{&1, jugador})

    assert Reglas.gano?(tablero, jugador)
    refute Reglas.gano?(Map.put(tablero, hd(destino), %{id: "dos"}), jugador)
  end
end
