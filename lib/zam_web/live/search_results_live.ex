defmodule ZamWeb.Live.SearchResultsLive do
  @moduledoc """
  The search form and results update live render
  """
  use ZamWeb, :live_view

  alias Zam.Search

  @autocomplete_keys ["ArrowDown", "ArrowUp"]


  def mount(params, _session, socket) do
    {:ok, search_init(socket, params)}
  end

  def handle_params(%{"t" => tag} = params, r, socket) do
    socket = socket
    |> assign(tag: tag)
    
    handle_params(Map.drop(params, ["t"]), r, socket)
  end

  def handle_params(%{"s" => search_for}, _, socket) do
    socket
    |> assign(search_for: search_for)
    |> search()
    |> no_reply()
  end

  def handle_params(_, _, socket) do
    socket
    |> no_reply()
  end

  def handle_event("search", %{"search" => %{"text" => search_for}}, socket) do
    socket = socket
    |> assign(search_for: search_for)

    socket
    |> push_patch(to: "/" <> build_search_params(socket.assigns))
    |> no_reply()
  end

  def handle_event("search_results_next_page", _, %{assigns: %{results: prev, search_for: search_for, offset: offset, tag: tag}} = socket) do
    results = search_for
    |> Search.query(offset, tag)
    |> Search.send!()

    offset = offset + Enum.count(results)

    search_results(search_for, Enum.take(prev ++ results, -60), offset, socket)
    |> no_reply()
  end

  def handle_event("suggest", %{"search" => %{"text" => ""}}, socket), do: {:noreply, socket}

  def handle_event("suggest", %{"search" => %{"text" => search_text}}, socket) do
    results = Search.suggest!(search_text)

    [_|rest] = Enum.reverse(String.split(search_text)) 

    {:noreply, suggest_results(Enum.join(Enum.reverse([List.first(results)|rest]), " "), socket)}
  end

  def handle_event("suggestion", value, socket) do
    results = Search.query(value)
    |> Search.send!()

    {:noreply, suggestion_selected(value, results, Enum.count(results), socket)}
  end

  def handle_event("complete_suggestion", %{"key" => key}, %{assigns: %{suggest: value, tag: tag}} = socket)
  when key in @autocomplete_keys do
    results = Search.query(value, 0, tag)
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
      tag: nil, 
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

  defp process_params(socket, %{"t" => tag} = params) do
    socket
    |> assign(tag: tag)
    |> process_params(Map.drop(params, ["t"]))
  end

  defp process_params(socket, _), do: socket

  defp search(%{assigns: %{search_for: search_for, tag: tag}} = socket) do
    results = search_for
    |> Search.query(0, tag)
    |> Search.send!()

    definition_results = Search.query_definitions!(search_for)

    offset = Enum.count(results)

    search_results(search_for, definition_results ++ results, offset, socket)
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
    socket
    |> assign(results: results, search_for: search_text, offset: offset, display_suggest: "none")
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

  defp build_search_params(assigns), do: build_search_params(assigns, :s, "?")

  defp build_search_params(%{search_for: s} = assigns, :s, params) when s in [nil, ""] do
    build_search_params(assigns, :t, params)
  end

  defp build_search_params(%{search_for: s} = assigns, :s, params) do
    build_search_params(assigns, :t, append_param(params, "s=#{s}"))
  end

  defp build_search_params(%{tag: t}, :t, params) when t in [nil, ""] do
    params
  end

  defp build_search_params(%{tag: t}, :t, params) do
    append_param(params, "t=#{t}")
  end

  defp append_param("?", param), do: "?#{param}"
  defp append_param(params, param), do: "#{params}&#{param}"

  defp no_reply(socket), do: {:noreply, socket}
end