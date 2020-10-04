defmodule Zam.Crawler.ParserLogic do
  @behaviour Crawlie.ParserLogic

  alias Zam.Crawler.Model.PageData
  alias Zam.Crawler.{ExtractTitles, ExtractText}
  alias Zam.Schema.QueryWeblinks

  alias Crawlie.Response


  def parse(%Response{} = response, _options) do
    case Response.content_type_simple(response) do
      "text/html" ->
        try do
          parsed = Floki.parse(response.body)

          {:ok, parsed}
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
  def extract_data(%{status_code: code, uri: uri} = response, parsed, options) do
    image_i = Keyword.fetch!(options, :image_i)
    i_id = Keyword.fetch!(options, :index_id)

    case code do
      200 ->
        title = ExtractTitles.get(parsed, :title)
        h1    = ExtractTitles.get(parsed, :h1)
        h2    = ExtractTitles.get(parsed, :h2)
        p     = ExtractText.get(parsed, :p, 3)
        img   = ExtractText.get(parsed, :img, image_i, uri.scheme, uri.host)

        [%PageData{index: i_id, uri: uri, code: code, img: img, title: title, headings: %{:h1 => h1, :h2 => h2}, text: p, samples: ""}]
      404 ->
        _ = QueryWeblinks.create_response_log(%{code: "404", referrer: Map.get(response, "referrer"), uri: URI.to_string(uri)})
        []
      _ ->
        []
    end
  end

  def extract_uris(response, parsed, options) do
    current_uri = response.uri

    hrefs = Floki.find(parsed, "a")
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
  defp valid_to_crawl(_, _, _, _), do: false
end