defmodule DamasChinasWeb.TableroLiveTest do
  use DamasChinasWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias DamasChinas.{GameServer, Salas}
  alias DamasChinasWeb.JugadorSession

  test "inicia desde el lobby y sincroniza una jugada entre los dos jugadores", %{conn: conn} do
    {:ok, %{codigo: codigo, host_id: host_id}} = Salas.crear_sala("Uno", :rojo)
    {:ok, %{jugador_id: invitado_id}} = Salas.unirse_sala(codigo, "Dos", :azul)

    {:ok, lobby, _} = live(conn, ~p"/lobby/#{codigo}")

    render_hook(lobby, "restore_jugador", %{"token" => JugadorSession.firmar(codigo, host_id)})
    lobby |> element("#lobby-iniciar") |> render_click()
    assert_redirect(lobby, ~p"/tablero/#{codigo}")

    {:ok, anfitrion, _} = live(conn, ~p"/tablero/#{codigo}")
    {:ok, invitado, _} = live(conn, ~p"/tablero/#{codigo}")
    assert has_element?(anfitrion, "#tablero-estrella")
    assert has_element?(anfitrion, "#casilla--3-3.tablero-ficha")
    assert has_element?(anfitrion, "#casilla--12-4.tablero-ficha")

    render_hook(anfitrion, "restore_jugador", %{"token" => host_id})
    assert has_element?(anfitrion, "#casilla--3-3[disabled]")

    render_hook(anfitrion, "restore_jugador", %{"token" => JugadorSession.firmar(codigo, host_id)})

    render_hook(invitado, "restore_jugador", %{
      "token" => JugadorSession.firmar(codigo, invitado_id)
    })

    assert has_element?(invitado, "#casilla--12-4[disabled]")

    assert {:error, :movimiento_invalido} =
             GameServer.mover(codigo, invitado_id, {-12, 4}, {-11, 5})

    assert {:error, :movimiento_invalido} =
             GameServer.mover(codigo, host_id, {-3, 3}, {-12, 4})

    anfitrion |> element("#casilla--3-3") |> render_click()
    assert has_element?(anfitrion, "#casilla--2-4.tablero-destino")
    anfitrion |> element("#casilla--2-4") |> render_click()

    assert has_element?(invitado, "#casilla--2-4.tablero-ficha")
    refute has_element?(invitado, "#casilla--3-3.tablero-ficha")
    assert has_element?(invitado, "#casilla--12-4:enabled")
    assert has_element?(invitado, "#tablero-estado", "Tu turno")
  end
end
