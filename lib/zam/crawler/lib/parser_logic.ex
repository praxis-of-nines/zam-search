defmodule Zam.Crawler.ParserLogic do
  @behaviour Crawlie.ParserLogic

  alias Zam.Crawler.Model.PageData
  alias Zam.Crawler.{ExtractTitles, ExtractText}

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
  def extract_data(%{status_code: code, uri: uri} = _response, parsed, _options) do    
    case code do
      200 ->
        title = ExtractTitles.get(parsed, :title)
        h1    = ExtractTitles.get(parsed, :h1)
        h2    = ExtractTitles.get(parsed, :h2)
        p     = ExtractText.get(parsed, :p, 3)

        [%PageData{uri: uri, code: code, title: title, headings: %{:h1 => h1, :h2 => h2}, text: p, samples: ""}]
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
        Enum.shuffle(Enum.filter(uris, &(valid_to_crawl(domain, &1.host, &1.path, options))))
      _ ->
        uris
    end
  end

  defp valid_to_crawl(_, _, nil, _), do: true # index page always valid
  defp valid_to_crawl(domain, host, path, options) when domain == host do
    rules = Keyword.get(options, :bot_rules)

    !String.contains?(path, Keyword.get(rules, :disallow, []))
  end
  defp valid_to_crawl(_, _, _, _), do: false
end