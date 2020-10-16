defmodule Zam.Crawler.PageParser do
  @moduledoc """
  Functions that receive a parsed page and page data and return these, updated
  with information extracted from the html. Note that each function narrows the
  search so wider scope (header / meta) functions should happen first before the
  scope of the html parse zeros in.
  """

  @doc """
  Extract what data is relevant to zam via page headers
  """
  def headers({parsed, page_data}, headers) do
    headers
    |> Enum.reduce(page_data, fn header, acc ->
      case header do
        {"Last-Modified", date} -> 
          %{acc | updated_at: Timex.parse!(date, "{RFC1123}")}
        _ -> 
          acc
      end
    end)
    |> return_tuple(parsed)
  end

  def timestamp(parse_tuple, nil), do: parse_tuple

  def timestamp({parsed, page_data}, content) do
    Floki.find(parsed, content)
    |> Floki.find(".date-header")
    |> List.first()
    |> timestamp_if(page_data)
    |> return_tuple(parsed)
  end

  defp timestamp_if(nil, page_data), do: page_data

  defp timestamp_if(timestamp_div, page_data) do
    timestamp = Floki.text(timestamp_div)

    %{page_data | updated_at: timestamp}
  end

  @doc """
  Extract page data from the meta contents
  """
  def meta({parsed, page_data}) do
    Floki.find(parsed, "meta")
    |> Enum.reduce(page_data, fn m, p_d ->
      Floki.attribute(m, "property")
      |> List.first()
      |> add_meta(m, p_d)
    end)
    |> return_tuple(parsed)
  end

  @doc """
  Extract data from the title tags
  """
  def titles({parsed, page_data}) do
    page_data = Floki.find(parsed, "h1")
    |> add_titles(:h1, page_data)

    Floki.find(parsed, "h2")
    |> Floki.text(sep: ",")
    |> add_titles(:h2, page_data)
    |> return_tuple(parsed)
  end

  @doc """
  Add images associated with the page by their url
  """
  def images({parsed, page_data}, nil, max, scheme, host) do
    Floki.find(parsed, "img")
    |> Enum.take(max)
    |> add_images(scheme, host, page_data)
    |> return_tuple(parsed)
  end

  def images({parsed, page_data}, content_location, max, scheme, host) do
    parsed = Floki.find(parsed, content_location)

    parsed
    |> Floki.find("img")
    |> Enum.take(max)
    |> add_images(scheme, host, page_data)
    |> images_if_empty(parsed, max, scheme, host)
  end

  @doc """
  Extract text blurbs from the page, either using the domains custom
  content tag if provided and found, or a generic paragraph search
  """
  def text({parsed, page_data}, nil, amount) do
    Floki.find(parsed, "p")
    |> add_text(amount, page_data)
    |> return_tuple(parsed)
  end

  def text({parsed, page_data}, content_location, amount) do
    content = Floki.find(parsed, content_location)

    content
    |> Floki.find("p")
    |> if_empty(content, "div")
    |> add_text(amount, page_data)
    |> return_tuple(parsed)
  end

  def page_title({parsed, page_data}) do
    Floki.find(parsed, "title")
    |> List.first()
    |> add_page_title(page_data)
    |> return_tuple(parsed)
  end

  # PRIVATE FUNCTIONS
  ###################
  defp add_meta("og:image", meta, %{img: nil} = page_data) do
    case Floki.attribute(meta, "content") do
      [img] -> add_image(img, page_data)
      _ -> page_data
    end
  end

  defp add_meta("article:published_time", meta, %{datetime: nil} = page_data) do
    datetime = Floki.attribute(meta, "content")
    |> List.first()

    %{page_data | inserted_at: datetime}
  end

  defp add_meta(_, _, page_data), do: page_data

  defp add_titles([parsed_title|_], :h1, %{headings: headings} = page_data) do
    headings = Map.put(headings, :h1, Floki.text(parsed_title))
    
    Map.put(page_data, :headings, headings)
  end

  defp add_titles(titles, :h2, %{headings: headings} = page_data) do
    headings = Map.put(headings, :h2, Floki.text(titles, sep: ","))
    
    Map.put(page_data, :headings, headings)
  end 

  defp add_titles(_, _, page_data), do: page_data

  defp add_text(paragraphs, amount, page_data) do
    paragraph_text = paragraphs
    |> Enum.slice(0..amount)
    |> Floki.text(sep: " ")

    %{page_data | text: paragraph_text}
  end

  defp add_page_title(nil, page_data), do: page_data

  defp add_page_title(title, page_data) do
    %{page_data | title: Floki.text(title)}
  end

  defp add_images([], _, _, page_data), do: page_data

  defp add_images([parsed_img|t], scheme, host, page_data) do
    page_data = Floki.attribute(parsed_img, "src")
    |> List.first()
    |> add_image(scheme, host, page_data)

    add_images(t, scheme, host, page_data)
  end

  defp add_image(nil, page_data), do: page_data

  defp add_image(img, %{img: nil, imgs: imgs} = page_data) do
    %{page_data | img: img, imgs: [img|imgs]}
  end

  defp add_image(img, %{imgs: imgs} = page_data) do
    %{page_data | imgs: [img|imgs]}
  end

  defp add_image(img, scheme, host, page_data) do
    case URI.parse(img) do
      %URI{host: nil} -> add_image("#{scheme}://#{host}/#{img}", page_data)
      _ -> add_image(img, page_data)
    end
  end

  defp images_if_empty(%{img: nil} = page_data, parsed, max, scheme, host) do
    images({parsed, page_data}, nil, max, scheme, host)
  end

  defp images_if_empty(page_data, parsed, _, _, _) do
    return_tuple(page_data, parsed)
  end

  defp if_empty([], parsed, content_location), do: Floki.find(parsed, content_location)

  defp if_empty(found_parsed, _, _), do: found_parsed

  defp return_tuple(page_data, parsed), do: {parsed, page_data}
end