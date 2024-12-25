defmodule PhotoUploaderPhoenix.Repo do
  use Ecto.Repo,
    otp_app: :photo_uploader_phoenix,
    adapter: Ecto.Adapters.SQLite3
end
