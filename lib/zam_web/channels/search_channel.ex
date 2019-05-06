defmodule ZamWeb.SearchChannel do
  use ZamWeb, :channel

  def join("search:" <> _topic, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("search", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (search:test).
  def handle_in("broadcast_search", payload, socket) do
    broadcast socket, "broadcast!", payload
    
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
