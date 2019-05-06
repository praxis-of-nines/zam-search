defmodule ZamWeb.Live.SearchResults do
  use Phoenix.LiveView

  alias ZamWeb.SearchView


  def mount(_session, socket) do
    {:ok, search_results(socket)}
  end

  def handle_event("search", %{"search" => %{"text" => _search_text}}, socket) do

    {:noreply, search_results_test(socket)}
  end

  def render(assigns) do
    SearchView.render("search.html", assigns)
  end

  defp search_results(socket) do
    assign(socket, results: [])
  end

  defp search_results_test(socket) do
    assign(socket, results: [%{
      title: "Infogalactic: the planetary knowledge core",
      link: "https://infogalactic.com/info/Main_Page"}])
  end
end