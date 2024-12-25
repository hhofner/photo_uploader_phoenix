defmodule PhotoUploaderPhoenixWeb.UploadController do
  use PhotoUploaderPhoenixWeb, :controller

  def redirect_to_uploads(conn, _params) do
    redirect(conn, to: ~p"/uploads")
  end
end
