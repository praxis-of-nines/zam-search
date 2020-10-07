defmodule Zam.Crawler.ExtractContent do
  @moduledoc """
  Extract text data. This tends to be bodies of content near the top of the page

  TODO: rename. Its for text and images
  """

  @doc """
  Retrieve top paragraphs

  ## Examples

    iex> ExtractText.get(:p, 3)
    {:ok, "this is a body of text this is another body of text", "2 p tags found"}
  """
  def get(parsed, :p, amt_retrieve, content) do

    p = case content do
      nil -> Floki.find(parsed, "p")
      content -> parsed
        |> Floki.find(content)
        |> Floki.find("p")
    end

    case Enum.count(p) do
      0 -> {:warning, nil, "no p tags"}
      amt_p -> {:ok, Enum.slice(p, 0..amt_retrieve) |> Floki.text(sep: " "), Integer.to_string(amt_p) <> " p tags found"}
    end
  end

  def get(parsed, :img, i, content, scheme, host) do
    meta = Floki.find(parsed, "meta")

    meta = meta
    |> Enum.filter(fn m ->
      List.first(Floki.attribute(m, "property")) == "og:image" 
    end)
    |> List.first()

    if meta do
      {:ok, List.first(Floki.attribute(meta, "content")), "og:image"}
    else
      get(:from_body, parsed, :img, i, content, scheme, host)
    end
  end

  def get(:from_body, parsed, :img, i, content, scheme, host) do
    img_result = if content do
      parsed
      |> Floki.find(content)
      |> Floki.find("img")
      |> Enum.fetch(0)
    end

    img_result = if !img_result do
      Floki.find(parsed, "img")
      |> Enum.fetch(i)
    else
      img_result
    end

    case img_result do
      {:ok, img} -> 
        img = Floki.attribute(img, "src")
        |> List.first()

        if img do
          case URI.parse(img) do
            %URI{host: nil} ->
              {:ok, "#{scheme}://#{host}/#{img}", "image #{i}"}
            _ ->
              {:ok, img, "image #{i}"}
          end
        else 
          {:error, nil, "no images found"}
        end
      _ -> 
        {:error, nil, "no images found"}
    end
  end
end