defmodule Zam.Search do
  @moduledoc """
  Search the index using basic defaults
  """
  alias Giza.SphinxQL
  alias Giza.Structs.SphinxqlResponse

  alias SimpleStatEx, as: SSX

  @page_size 20


  @doc """
  The basic search among indexed webpages.  Note if blank search requested the search is done with identical params
  but likely a more specific edge case should be used.

  ## Example

    iex > Search.query!("chinggis kahn")
    [%{title: "Travelling in the Bloody Footsteps..", description: "..", link: "www.example.com.."}, ..]
  """
  def query(_, offset \\ 0)

  def query("", offset) do
    SphinxQL.new()
    |> SphinxQL.from("i_weblink")
    |> SphinxQL.where("MATCH('')")
    |> SphinxQL.option("ranker = expr('sum(score_link * 0.1) + sum(score_zam * 0.15) + sum(lcs*user_weight)*1000 +bm25')")
    |> SphinxQL.order_by("WEIGHT() DESC")
    |> SphinxQL.offset(offset)
    |> SphinxQL.limit(@page_size)
    |> SphinxQL.send()
  end

  def query(text, offset) do
    SphinxQL.new()
    |> SphinxQL.from("i_weblink")
    |> SphinxQL.where("MATCH('*#{text}*')")
    |> SphinxQL.option("ranker = expr('sum(score_link * 0.1) + sum(score_zam * 0.15) + sum(lcs*user_weight)*1000 +bm25')")
    |> SphinxQL.order_by("WEIGHT() DESC")
    |> SphinxQL.offset(offset)
    |> SphinxQL.limit(@page_size)
    |> SphinxQL.send()
  end

  def query_definitions(text) do
    SphinxQL.new()
    |> SphinxQL.from("i_definition")
    |> SphinxQL.where("MATCH('@title *#{text}*')")
    |> SphinxQL.order_by("WEIGHT() DESC")
    |> SphinxQL.offset(0)
    |> SphinxQL.limit(1)
    |> SphinxQL.send()
  end

  def query!(_, offset \\ 0)

  def query!(text, offset) do
    case query(text, offset) do
      {:ok, %SphinxqlResponse{matches: matches}} -> 
        Enum.reverse(Enum.reduce(matches, [], fn [_id, title, link, desc|_], acc ->
          [%{title: title, link: link, description: desc}|acc]
        end))
      {:error, _error} ->
        # Log error details here as well
        _ = SSX.stat("sphinx search error", :hourly) |> SSX.save()

        []
    end
  end

  def query_definitions!(text) do
    case query_definitions(text) do
      {:ok, %SphinxqlResponse{matches: matches}} -> 
        Enum.reverse(Enum.reduce(matches, [], fn [_id, title, desc, example|_], acc ->
          [%{title: title, description: desc, example: example}|acc]
        end))
      {:error, _error} ->
        # Log error details here as well
        _ = SSX.stat("sphinx search definition error", :hourly) |> SSX.save()

        []
    end
  end

  @doc """
  Return suggestions for a given string of text
  """
  def suggest(text) do
    SphinxQL.new() 
    |> SphinxQL.suggest("i_weblink", text)
    |> SphinxQL.send()
  end

  def suggest!(text) do
    case suggest(text) do
      {:ok, %SphinxqlResponse{matches: matches}} ->
        Enum.reverse(Enum.reduce(matches, [], fn [match, _distance, _docs], acc ->
          [match|acc]
        end))
      {:error, _error} ->
        _ = SSX.stat("sphinx suggest error", :hourly) |> SSX.save()

        []
    end
  end
end
