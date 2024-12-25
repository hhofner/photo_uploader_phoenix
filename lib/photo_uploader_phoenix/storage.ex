defmodule PhotoUploaderPhoenix.Storage do
  @moduledoc """
  Handles file storage operations with Cloudflare R2 (dummy implementation for now)
  """

  def upload(path, filename, description) do
    # Dummy implementation - will be replaced with actual R2 upload
    # For now, we'll still save locally but prepare the interface
    dest = Path.join(["priv", "static", "uploads", filename])
    File.cp!(path, dest)
    
    # Return a dummy URL that matches what we'd expect from R2
    {:ok, %{url: "/uploads/#{filename}", description: description}}
  end

  def delete(filename) do
    # Dummy implementation - will be replaced with actual R2 delete
    {:ok, filename}
  end
end
