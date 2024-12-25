defmodule PhotoUploaderPhoenix.Storage do
  @moduledoc """
  Handles file storage operations with Cloudflare R2
  """

  require Logger

  def upload(path, filename, description) do
    bucket = System.get_env("R2_BUCKET_NAME")

    # Upload the image file
    image_result = ExAws.S3.put_object(bucket, filename, File.read!(path))
    |> ExAws.request()

    # Create and upload metadata JSON
    metadata = %{
      filename: filename,
      description: description,
      uploaded_at: DateTime.utc_now() |> DateTime.to_iso8601()
    }
    
    metadata_filename = "#{Path.rootname(filename)}.json"
    metadata_result = ExAws.S3.put_object(
      bucket,
      "metadata/#{metadata_filename}",
      Jason.encode!(metadata)
    )
    |> ExAws.request()

    case {image_result, metadata_result} do
      {{:ok, _}, {:ok, _}} ->
        host = System.get_env("R2_HOST")
        url = "https://#{host}/#{bucket}/#{filename}"
        {:ok, %{url: url, description: description}}
      
      {image_err, metadata_err} ->
        Logger.error("Failed to upload - Image: #{inspect(image_err)}, Metadata: #{inspect(metadata_err)}")
        {:error, "Failed to upload file"}
    end
  end

  def delete(filename) do
    bucket = System.get_env("R2_BUCKET_NAME")
    
    # Delete both the image and its metadata
    metadata_filename = "#{Path.rootname(filename)}.json"
    
    with {:ok, _} <- ExAws.S3.delete_object(bucket, filename) |> ExAws.request(),
         {:ok, _} <- ExAws.S3.delete_object(bucket, "metadata/#{metadata_filename}") |> ExAws.request() do
      {:ok, filename}
    else
      error ->
        Logger.error("Failed to delete file: #{inspect(error)}")
        {:error, "Failed to delete file"}
    end
  end

  def get_metadata(filename) do
    bucket = System.get_env("R2_BUCKET_NAME")
    metadata_filename = "metadata/#{Path.rootname(filename)}.json"
    
    case ExAws.S3.get_object(bucket, metadata_filename) |> ExAws.request() do
      {:ok, %{body: body}} -> 
        Jason.decode(body)
      error ->
        Logger.error("Failed to get metadata: #{inspect(error)}")
        {:error, "Failed to get metadata"}
    end
  end
end
