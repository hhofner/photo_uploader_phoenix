defmodule PhotoUploaderPhoenixWeb.SessionController do
  use PhotoUploaderPhoenixWeb, :controller

  def create(conn, %{"password" => password}) do
    correct_password = System.get_env("AUTH_PASSWORD") || "password123"

    if password == correct_password do
      conn
      |> put_session(:authenticated, true)
      |> redirect(to: ~p"/uploads")
    else
      conn
      |> put_flash(:error, "Invalid password")
      |> redirect(to: ~p"/login")
    end
  end

  def delete(conn, _params) do
    conn
    |> clear_session()
    |> redirect(to: ~p"/login")
  end
end
