defmodule Zam.Crawler.ParserLogic do
  @behaviour Crawlie.ParserLogic

  alias Zam.Crawler.Model.PageData
  alias Zam.Crawler.PageParser
  alias Zam.Schema.QueryWeblinks

  alias Crawlie.Response

  @max_paragraphs 3
  @max_images_per_page 3

  def parse(%Response{} = response, _options) do
    case Response.content_type_simple(response) do
      "text/html" ->
        try do
          Floki.parse_document(response.body)
        rescue
          e in CaseClauseError -> 
            IO.inspect e
            {:error, :case_clause_error}
          e in RuntimeError -> 
            IO.inspect e
            {:error, :runtime_error}
        end
      _unsupported ->
        {:skip, :unsupported_content_type}
    end
  end

  @doc """
  Extract the meaningful (to search) data from the page along with identifying information
  for final processing.
  """
  def extract_data(%{status_code: code, uri: uri, headers: headers} = response, parsed, options) do
    content = Keyword.fetch!(options, :content)
    i_id = Keyword.fetch!(options, :index_id)

    cond do
      code >= 200 && code < 300 ->
        {parsed, %PageData{uri: uri}}
        |> PageParser.headers(headers)
        |> PageParser.url(uri)
        |> PageParser.page_title()
        |> PageParser.meta()
        |> PageParser.titles()
        |> PageParser.text(content, @max_paragraphs)
        |> PageParser.images(content, @max_images_per_page, uri.scheme, uri.host)
        |> elem(1)
        |> Map.put(:index, i_id)
        |> List.duplicate(1)
      code == 404 ->
        _ = %{code: "404", uri: URI.to_string(uri)}
        |> Map.put(:referrer, Map.get(response, "referrer"))
        |> QueryWeblinks.create_response_log()
        []
      true ->
        []
    end
  end

  def extract_uris(response, parsed, options) do
    current_uri = response.uri

    hrefs = parsed
    |> Floki.find("a")
    |> Floki.filter_out("[rel=nofollow]")
    |> Floki.attribute("a", "href")

    uris = Enum.map(hrefs, &URI.merge(current_uri, &1))

    # Reject any url's outside of domain and respect robots
    case Keyword.get(options, :domain) do
      domain when is_binary(domain) ->
        # Shuffle creates a situation where we visit different pages first each crawl, so
        # there is variety in the case of a max visits interrupt
        uris
        |> Enum.filter(&(valid_to_crawl(String.trim(domain, "/"), &1.host, &1.path, options)))
        |> Enum.shuffle()
      _ ->
        uris
    end
  end

  defp valid_to_crawl(domain, host, nil, _) when domain == host, do: true # index page always valid
  defp valid_to_crawl(domain, host, path, options) when domain == host do
    rules = Keyword.get(options, :bot_rules)

    !String.contains?(path, Keyword.get(rules, :disallow, []))
  end
  defp valid_to_crawl(domain, host, _, _) do
    false
  end
end