defmodule ZamWeb.Live.ImageSearchResultsLive do
  @moduledoc """
  The search form and results update live render
  """
  use ZamWeb, :live_view

  alias Zam.Search

  @autocomplete_key "Tab"


  @doc """
  Set default form and result arguments
  """
  def mount(params, _session, socket) do
    {:ok, search_init(socket, params)}
  end

  @doc """
  Search results requested
  """
  def handle_event("search", %{"search" => %{"text" => search_for}}, socket) do
    socket
    |> assign(search_for: search_for)
    |> search()
    |> no_reply()
  end

  def handle_event("search_results_next_page", _, %{assigns: %{search_for: search_for, offset: offset}} = socket) do
    results = search_for
    |> Search.query_images(offset)
    |> Search.send!()

    offset = offset + Enum.count(results)

    search_results(search_for, results, offset, socket)
    |> no_reply()
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
    results = Search.query_images(value)
    |> Search.send!()

    {:noreply, suggestion_selected(value, results, Enum.count(results), socket)}
  end

  def handle_event("complete_suggestion", @autocomplete_key, %{assigns: %{suggest: value}} = socket) do
    results = value
    |> Search.query_images(0)
    |> Search.send!()

    {:noreply, suggestion_selected(value, results, Enum.count(results), socket)}
  end

  def handle_event("complete_suggestion", _key, socket) do
    {:noreply, socket}
  end

  # PRIV
  #############################
  defp search_init(socket, params) do
    socket
    |> assign(
      results: [], 
      search_for: "",
      suggest: "", 
      display_suggest: "none", 
      offset: 0)
    |> process_params(params)
  end

  defp process_params(socket, %{"s" => search_for} = params) do
    socket
    |> assign(search_for: search_for)
    |> process_params(Map.drop(params, ["s"]))
    |> search()
  end

  defp process_params(socket, _), do: socket

  defp search(%{assigns: %{search_for: search_for}} = socket) do
    results = search_for
    |> Search.query_images(0)
    |> Search.send!()
    |> Enum.uniq_by(fn %{url: url} -> url end)

    offset = Enum.count(results)

    search_results(search_for, results, offset, socket)
  end

  defp search_results(search_text, [], _, socket) do
    empty_result(search_text, socket)
  end

  defp search_results(search_text, results, offset, socket) do
    assign(socket, 
      results: results,
      search_for: search_text,
      offset: offset,
      display_suggest: "none"
    )
  end

  defp suggest_results(nil, socket) do
    assign(socket, suggest: "", display_suggest: "none")
  end

  defp suggest_results(suggestion, socket) do
    assign(socket, suggest: suggestion, display_suggest: "block")
  end

  defp suggestion_selected(search_text, [], _, socket) do
    empty_result(search_text, socket)
  end

  defp suggestion_selected(search_text, results, offset, socket) do
    assign(socket, results: results, search_for: search_text, offset: offset, display_suggest: "none")
  end

  defp empty_result(search_text, socket) do
    assign(socket, 
      results: [%{
        description: "No results found for " <> search_text,
        link: "",
        title: ""
      }],
      offset: 0,
      search_for: search_text,
      display_suggest: "none"
    )
  end

  defp no_reply(socket), do: {:noreply, socket}
end