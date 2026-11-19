defmodule DamasChinasWeb.JugadorSession do
  @moduledoc false

  alias DamasChinasWeb.Endpoint

  @vigencia_segundos 24 * 60 * 60

  def firmar(codigo, jugador_id) do
    Phoenix.Token.sign(Endpoint, "jugador de sala", {codigo, jugador_id})
  end

  def verificar(token, codigo) do
    with {:ok, {^codigo, jugador_id}} <-
           Phoenix.Token.verify(Endpoint, "jugador de sala", token, max_age: @vigencia_segundos) do
      {:ok, jugador_id}
    else
      _ -> :error
    end
  end
end
