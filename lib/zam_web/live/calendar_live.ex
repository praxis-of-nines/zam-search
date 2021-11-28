defmodule ZamWeb.Live.CalendarLive do
  @moduledoc """
  The calendar of enoch live widget
  """
  use ZamWeb, :live_view

  alias EnochEx.Calendar.Model.CurrentDatetime, as: CDT
  alias Phoenix.PubSub

  
  def mount(params, _session, socket) do
    {:ok, enoch_init(socket, params)}
  end

  def handle_info(%CDT{} = cdt, socket) do
    socket
    |> assign(cdt: EnochEx.Calendar.CurrentDatetime.pretty(cdt))
    |> no_reply()
  end

  def handle_event("city", %{"city" => city}, socket) do
    socket
    |> assign_calendar(city)
    |> no_reply()
  end

  # PRIV
  #############################
  defp enoch_init(socket, %{"l" => city} = params) do
    socket
    |> assign_calendar(city)
    |> enoch_init(Map.drop(params, ["l"]))
  end

  defp enoch_init(socket, _params) do
    _ = PubSub.subscribe(Zam.PubSub, "calendar_ticker")

    socket
    |> assign(cdt: EnochEx.now())
  end

  defp assign_calendar(socket, city) do
    city
    |> EnochEx.now()
    |> assign_to_socket(:cdt, socket)
  end

  defp no_reply(socket), do: {:noreply, socket}
  defp assign_to_socket(val, key, socket), do: assign(socket, [{key, val}])
end