defmodule DamasChinas.GameServerTest do
  use ExUnit.Case, async: false

  alias DamasChinas.GameServer
  alias DamasChinas.Salas

  # Crea una sala con dos jugadores y devuelve {codigo, host, invitado}
  defp sala_con_dos do
    {:ok, %{codigo: codigo, host_id: j1}} = Salas.crear_sala("Uno", :rojo)
    {:ok, %{jugador_id: j2}} = Salas.unirse_sala(codigo, "Dos", :azul)
    {codigo, j1, j2}
  end

  test "no se puede usar un color que ya tiene otro jugador" do
    {:ok, %{codigo: codigo}} = Salas.crear_sala("Uno", :rojo)
    assert {:error, :color_tomado} = Salas.unirse_sala(codigo, "Dos", :rojo)
  end

  test "la sala acepta como máximo 6 jugadores (uno por color)" do
    {:ok, %{codigo: codigo}} = Salas.crear_sala("Uno", :rojo)
    {:ok, _} = Salas.unirse_sala(codigo, "Dos", :azul)
    {:ok, _} = Salas.unirse_sala(codigo, "Tres", :verde)
    {:ok, _} = Salas.unirse_sala(codigo, "Cuatro", :amarillo)
    {:ok, _} = Salas.unirse_sala(codigo, "Cinco", :morado)
    {:ok, _} = Salas.unirse_sala(codigo, "Seis", :naranja)
    assert {:error, :sala_llena} = Salas.unirse_sala(codigo, "Siete", :rojo)
  end

  test "solo el anfitrión puede iniciar y hacen falta 2 jugadores" do
    {:ok, %{codigo: codigo, host_id: j1}} = Salas.crear_sala("Uno", :rojo)
    assert {:error, :pocos_jugadores} = GameServer.iniciar(codigo, j1)

    {:ok, %{jugador_id: j2}} = Salas.unirse_sala(codigo, "Dos", :azul)
    assert {:error, :no_es_host} = GameServer.iniciar(codigo, j2)
    assert {:ok, %{fase: :jugando, turno_idx: 0}} = GameServer.iniciar(codigo, j1)
  end

  test "volver al lobby deja la sala esperando otra vez" do
    {codigo, j1, j2} = sala_con_dos()
    {:ok, _} = GameServer.iniciar(codigo, j1)

    assert {:ok, %{fase: :esperando}} = GameServer.rendirse(codigo, j2)
  end

  test "si se va el anfitrión, el siguiente jugador pasa a ser anfitrión" do
    {codigo, j1, j2} = sala_con_dos()
    GameServer.salir(codigo, j1)

    {:ok, estado} = GameServer.get_estado(codigo)
    assert estado.host_id == j2
    assert Enum.map(estado.jugadores, & &1.id) == [j2]
  end

  test "si en plena partida queda un solo jugador, la partida termina" do
    {codigo, j1, j2} = sala_con_dos()
    {:ok, _} = GameServer.iniciar(codigo, j1)
    GameServer.salir(codigo, j2)

    {:ok, estado} = GameServer.get_estado(codigo)
    assert estado.fase == :finalizada
  end
end
