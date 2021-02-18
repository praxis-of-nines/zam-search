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
        # Taking out, doesn't give enough
        #{"Last-Modified", date} -> 
        #  %{acc | updated_at: Timex.parse!(date, "{RFC1123}")}
        _ -> 
          acc
      end
    end)
    |> return_tuple(parsed)
  end

  @doc """
  Extract data from the url such as the date of the post if it's in a format
  such as /2020/10/05/.. or /2020/10/..
  """
  def url(parsed_tuple, %{path: nil}), do: parsed_tuple
  def url({parsed, page_data}, %{path: path}) do    
    path
    |> String.trim("/")
    |> String.split("/")
    |> date_from_url_parts({{nil, nil, nil}, {0, 0, 0}}, page_data)
    |> return_tuple(parsed)
  end

  @doc """
  Extract page data from the meta contents
  """
  def meta({parsed, page_data}) do
    parsed
    |> Floki.find("meta")
    |> Enum.reduce(page_data, fn meta, page_data ->
      property = meta
      |> Floki.attribute("property")
      |> List.first()

      name = meta
      |> Floki.attribute("name")
      |> List.first()

      page_data
      |> add_meta(property, meta)
      |> add_meta(name, meta)
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
  def text({parsed, page_data}, nil, _) do
    parsed
    |> add_text(page_data)
    |> return_tuple(parsed)
  end

  def text({parsed, page_data}, content_location, _) do
    content = Floki.find(parsed, content_location)

    content
    |> add_text(page_data)
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
  defp add_meta(page_data, "og:description", meta), do: add_meta(page_data, "description", meta)

  defp add_meta(page_data, "description", meta) do
    case Floki.attribute(meta, "content") do
      [desc] -> Map.put(page_data, :text, desc)
      _ -> page_data
    end
  end

  defp add_meta(%{img: nil} = page_data, "og:image", meta) do
    case Floki.attribute(meta, "content") do
      [img] -> add_image(img, page_data)
      _ -> page_data
    end
  end

  defp add_meta(%{datetime: nil} = page_data, "article:published_time", meta) do
    datetime = Floki.attribute(meta, "content")
    |> List.first()

    %{page_data | inserted_at: datetime}
  end

  defp add_meta(page_data, _, _), do: page_data

  defp add_titles([parsed_title|_], :h1, %{headings: headings} = page_data) do
    headings = Map.put(headings, :h1, Floki.text(parsed_title))
    
    Map.put(page_data, :headings, headings)
  end

  defp add_titles(titles, :h2, %{headings: headings} = page_data) do
    headings = Map.put(headings, :h2, Floki.text(titles, sep: ","))
    
    Map.put(page_data, :headings, headings)
  end 

  defp add_titles(_, _, page_data), do: page_data

  defp add_text(content, page_data) do
    paragraph_text = content
    |> Floki.text(sep: " ")

    case Map.get(page_data, :text) do
      nil -> Map.put(page_data, :text, paragraph_text)
      prev_text -> Map.put(page_data, :text, prev_text <> " " <> paragraph_text)
    end
  end

  defp add_page_title(nil, page_data), do: page_data

  defp add_page_title(title, page_data) do
    Map.put(page_data, :title, Floki.text(title))
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

  defp add_image(nil, _, _, page_data), do: page_data

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

  defp return_tuple(page_data, parsed), do: {parsed, page_data}

  defp date_from_url_parts([year|t], {{nil, month, day}, time} = erltime, page_data) do
    if String.length(year) == 4 && year =~ ~r/2[0-9][0-9][0-9]/ do
      date_from_url_parts(t, {{String.to_integer(year), month, day}, time}, page_data)
    else
      date_from_url_parts(t, erltime, page_data)
    end
  end

  defp date_from_url_parts([month|t], {{year, nil, day}, time}, page_data) when not is_nil(year) do
    if String.length(month) < 3 && (month =~ ~r/[0-2][1-9]/ || month =~ ~r/[1-9]/) do
      date_from_url_parts(t, {{year, String.to_integer(month), day}, time}, page_data)
    else
      page_data
    end
  end

  defp date_from_url_parts([day|_], {{year, month, nil}, time}, page_data) when not is_nil(year) and not is_nil(month) do
    datetime = if String.length(day) < 3 && (day =~ ~r/[0-3][0-9]/ || day =~ ~r/[0-9]/) do
      {{year, month, String.to_integer(day)}, time}
      |> Timex.to_datetime("Etc/UTC")
      |> Timex.to_naive_datetime()
    else
      {{year, month, 1}, time}
      |> Timex.to_datetime("Etc/UTC")
      |> Timex.to_naive_datetime()
    end

    %{page_data | updated_at: datetime}
  end

  defp date_from_url_parts(_, {{year, month, _}, time}, page_data) when not is_nil(year) and not is_nil(month) do
    datetime = {{year, month, 1}, time}
    |> Timex.to_datetime("Etc/UTC")
    |> Timex.to_naive_datetime()

    %{page_data | updated_at: datetime}
  end

  defp date_from_url_parts([_|t], erl_time, page_data) do
    date_from_url_parts(t, erl_time, page_data)
  end

  defp date_from_url_parts(_, _, page_data), do: page_data
end