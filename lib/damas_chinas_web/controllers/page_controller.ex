defmodule DamasChinasWeb.PageController do
  use DamasChinasWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
