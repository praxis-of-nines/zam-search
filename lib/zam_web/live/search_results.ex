defmodule ZamWeb.Live.SearchResults do
  @moduledoc """
  The search form and results update live render
  """
  use Phoenix.LiveView

  alias ZamWeb.SearchView
  alias Zam.Search

  @autocomplete_key "Tab"


  @doc """
  Set default form and result arguments
  """
  def mount(_session, socket) do
    {:ok, search_init(socket)}
  end

  @doc """
  Search results requested
  """
  def handle_event("search", %{"search" => %{"text" => search_text}}, socket) do
    results = Search.query!(search_text)

    {:noreply, search_results(search_text, results, socket)}
  end

  @doc """
  Produce search suggestions
  """
  def handle_event("suggest", %{"search" => %{"text" => ""}}, socket), do: {:noreply, socket}

  def handle_event("suggest", %{"search" => %{"text" => search_text}}, socket) do
    results = Search.suggest!(search_text)

    [_|rest] = Enum.reverse(String.split(search_text)) 

    {:noreply, suggest_results(Enum.join(Enum.reverse([List.first(results)|rest]), " "), socket)}
  end

  @doc """
  Use a search suggestion
  """
  def handle_event("suggestion", value, socket) do
    results = Search.query!(value)

    {:noreply, suggestion_selected(value, results, socket)}
  end

  def handle_event("complete_suggestion", @autocomplete_key, %{assigns: %{suggest: value}} = socket) do
    results = Search.query!(value)

    {:noreply, suggestion_selected(value, results, socket)}
  end

  def handle_event("complete_suggestion", _key, socket) do
    {:noreply, socket}
  end

  @doc """
  Render template
  """
  def render(assigns) do
    SearchView.render("search.html", assigns)
  end

  # PRIV
  #############################
  defp search_init(socket) do
    assign(socket, results: [], search_for: "", suggest: "", display_suggest: "none")
  end

  defp search_results(search_text, [], socket) do
    empty_result(search_text, socket)
  end

  defp search_results(search_text, results, socket) do
    assign(socket, 
      results: results,
      search_for: search_text,
      display_suggest: "none"
    )
  end

  defp suggest_results(nil, socket) do
    assign(socket, suggest: "", display_suggest: "none")
  end

  defp suggest_results(suggestion, socket) do
    assign(socket, suggest: suggestion, display_suggest: "block")
  end

  defp suggestion_selected(search_text, [], socket) do
    empty_result(search_text, socket)
  end

  defp suggestion_selected(search_text, results, socket) do
    assign(socket, results: results, search_for: search_text, display_suggest: "none")
  end

  defp empty_result(search_text, socket) do
    assign(socket, 
      results: [%{
        description: "No results found for " <> search_text,
        link: "",
        title: ""
      }],
      search_for: search_text,
      display_suggest: "none"
    )
  end
end