defmodule PhotoUploaderPhoenixWeb.LoginController do
  use PhotoUploaderPhoenixWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
