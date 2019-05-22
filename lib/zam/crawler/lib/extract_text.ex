defmodule Zam.Crawler.ExtractText do
  @moduledoc """
  Extract text data. This tends to be bodies of content near the top of the page
  """

  @doc """
  Retrieve top paragraphs

  ## Examples

    iex> ExtractText.get(:p, 3)
    {:ok, "this is a body of text this is another body of text", "2 p tags found"}
  """
  def get(parsed, :p, amt_retrieve) do
    p = Floki.find(parsed, "p")

    case Enum.count(p) do
      0 -> {:warning, nil, "no p tags"}
      amt_p -> {:ok, Enum.slice(p, 0..amt_retrieve) |> Floki.text(sep: " "), Integer.to_string(amt_p) <> " p tags found"}
    end
  end
end