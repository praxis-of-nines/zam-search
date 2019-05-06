defmodule Zam.Crawler.ParserLogic do
  @behaviour Crawlie.ParserLogic

  alias Crawlie.Response


  def parse(%Response{} = response, _options) do
    case Response.content_type_simple(response) do
      "text/html" ->
        try do
          parsed = Floki.parse(response.body)
  
          _ = :ets.update_counter(:crawler_counts, :pages_parsed, {2, 1}, {:pages_parsed, 0})

          {:ok, parsed}
        rescue
          _e in CaseClauseError -> {:error, :case_clause_error}
          _e in RuntimeError -> {:error, :runtime_error}
        end
      _unsupported ->
        {:skip, :unsupported_content_type}
    end
  end

  def extract_data(_response, _parsed, _options) do
    #prices = Floki.find(parsed, "#ciItemPrice")
    #|> Floki.attribute("value")

    #Enum.each(prices, fn price ->
    #  {price_int, _} = Integer.parse(price)
    #  :ets.update_counter(:crawler_counts, :price_total, {2, price_int}, {:price_total, 0})
    #  :ets.update_counter(:crawler_counts, :items_found, {2, 1}, {:items_found, 0})
    #end)

    #  prices

    #text = Floki.text(prices, sep: " ")
    #[]
    #String.split(text, [" ", "\ "], trim: true)
    #|> Enum.filter(&(String.length(&1) > 5))
    #|> Enum.map(&String.downcase/1)

    []
  end

  def extract_uris(response, parsed, options) do
    current_uri = response.uri

    hrefs = Floki.find(parsed, "a")
    |> Floki.filter_out("[rel=nofollow]")
    |> Floki.attribute("a", "href")
    
    uris = Enum.map(hrefs, &URI.merge(current_uri, &1))

    # Reject any url's outside of domain
    case Keyword.get(options, :domain) do
      domain when is_binary(domain) ->
        Enum.filter(uris, &(&1.host == domain))
      _ ->
        uris
    end
  end
end