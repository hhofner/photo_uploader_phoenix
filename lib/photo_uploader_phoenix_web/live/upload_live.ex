defmodule PhotoUploaderPhoenixWeb.UploadLive do
  use PhotoUploaderPhoenixWeb, :live_view
  
  alias PhotoUploaderPhoenix.Storage

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> assign(:descriptions, %{})
     |> allow_upload(:images, 
       accept: ~w(.jpg .jpeg .png),
       max_entries: 10,
       max_file_size: 10_000_000)}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket |> validate_uploads(:images)}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :images, ref)}
  end

  def handle_event("update-description", %{"ref" => ref, "description" => description}, socket) do
    {:noreply, update(socket, :descriptions, &Map.put(&1, ref, description))}
  end

  @impl true
  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :images, fn %{path: path}, entry ->
        filename = entry.client_name
        description = Map.get(socket.assigns.descriptions, entry.ref, "")
        Storage.upload(path, filename, description)
      end)

    {:noreply, 
     socket 
     |> update(:uploaded_files, &(&1 ++ uploaded_files))
     |> assign(:descriptions, %{})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl">
      <h1 class="text-2xl font-bold mb-4">Photo Upload</h1>
      
      <form phx-submit="save" phx-change="validate">
        <div class="mb-4">
          <.live_file_input upload={@uploads.images} class="hidden" />
          <div class="bg-gray-50 p-4 rounded-lg border-2 border-dashed border-gray-300 text-center cursor-pointer"
               phx-drop-target={@uploads.images.ref}>
            <p class="text-gray-600">Click to select or drag photos here</p>
          </div>
        </div>

        <div class="space-y-4">
          <%= for entry <- @uploads.images.entries do %>
            <div class="flex items-center space-x-4">
              <.live_img_preview entry={entry} class="w-20 h-20 object-cover rounded" />
              <div class="flex-1">
                <div class="text-sm"><%= entry.client_name %></div>
                <div class="text-xs text-gray-500">
                  <%= entry.progress %>%
                </div>
                <input type="text" 
                       placeholder="Add description..."
                       class="mt-1 w-full text-sm border rounded p-1"
                       value={@descriptions[entry.ref]}
                       phx-blur="update-description"
                       phx-value-ref={entry.ref} />
                <%= for err <- upload_errors(@uploads.images, entry) do %>
                  <div class="text-red-500 text-xs"><%= err %></div>
                <% end %>
              </div>
              <button type="button" class="text-red-500"
                      phx-click="cancel-upload"
                      phx-value-ref={entry.ref}>×</button>
            </div>
          <% end %>
        </div>

        <div class="mt-4">
          <button type="submit" class="w-full bg-blue-500 text-white py-2 px-4 rounded-lg hover:bg-blue-600">
            Upload Photos
          </button>
        </div>
      </form>

      <div class="mt-8">
        <h2 class="text-xl font-bold mb-4">Uploaded Photos</h2>
        <div class="grid grid-cols-2 gap-4">
          <%= for %{url: url, description: description} <- @uploaded_files do %>
            <div class="space-y-1">
              <img src={url} class="w-full h-40 object-cover rounded-lg" />
              <%= if description && description != "" do %>
                <p class="text-sm text-gray-600"><%= description %></p>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
