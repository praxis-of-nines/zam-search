defmodule Zam.Crawler.ExtractTitles do
  @moduledoc """
  Extract title data deemed relevent from parsed html
  """

  @doc """
  Retrieve titles along with information regarding indexability of said titles. Returns
  a comment explaining any warnings.

  ## Examples

    iex> ExtractTitles.get(..)
    {:warning, "This is the main title!", "too many h1 tags"}
  """
  def get(parsed, :h1) do
    h1s = Floki.find(parsed, "h1")

    case Enum.count(h1s) do
      0 -> {:warning, nil, "no h1 tag"}
      1 -> {:ok, h1s |> Floki.text(), "single h1 found"}
      _ -> {:warning, h1s |> List.first() |> Floki.text(), "too many h1 tags"}
    end
  end

  def get(parsed, :h2) do
    h2s = Floki.find(parsed, "h2")

    case Enum.count(h2s) do
      0 -> {:warning, nil, "no h2 tags"}
      _ -> {:ok, h2s |> Floki.text(sep: ","), "h2 found"}
    end
  end

  def get(parsed, :title) do
    title = Floki.find(parsed, "title")

    case Enum.count(title) do
      0 -> {:warning, nil, "no page title"}
      1 -> {:ok, title |> Floki.text(), "title found"}
      _ -> {:warning, title |> List.first() |> Floki.text(), "multiple titles found"}
    end
  end
end