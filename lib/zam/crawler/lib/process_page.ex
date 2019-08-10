defmodule Zam.Crawler.ProcessPage do
  @moduledoc """
  Handle the given PageData and hand it to our system storage

  %PageData{uri: %{}, title: "", code: 200, headings: %{:h1 => [], :h2 => []}, text: "", samples: ""}
  """
  alias Zam.Crawler.Model.PageData
  alias Zam.Crawler.Stats
  alias Zam.Schema.QueryWeblinks

  @description_max 225
  @title_max 120
  @longtext_max 3000


  @doc """
  Store the extracted data that make up the parts of a page search is interested in
  """
  def store_page_data(%PageData{} = page_data) do
    weblink_attr = build_weblink_data(%{}, :link, page_data)
    |> build_weblink_data(:samples, page_data)
    |> build_weblink_data(:description, page_data)
    |> build_weblink_data(:title, page_data)

    webtext_attr = build_weblink_data(%{}, :longtext, page_data)

    case Enum.empty?(weblink_attr) do
      true -> {:error, "no data extracted"}
      false -> 
        results = store_weblink(%{link: weblink_attr.link}, weblink_attr)
        |> store_text_blob(webtext_attr)

        {:ok, results}
    end
  end

  def store_weblink(acc, attr) do
    case QueryWeblinks.get_weblink(attr.link) do
      nil ->
        case QueryWeblinks.create_weblink(attr) do
          {:ok, %{link: link}} -> 
            %{id: weblink_id} = QueryWeblinks.get_weblink(link)
            Map.put(acc, :weblink, weblink_id)
          {:error, _error} ->
            acc
        end
      _ -> 
        # "recently stored"
        acc
    end
  end

  def store_text_blob(%{:weblink => weblink_id} = acc, attr) when is_integer(weblink_id) do
    case QueryWeblinks.get_text_blob(weblink_id) do
      nil ->
        case QueryWeblinks.create_text_blob(attr) do
          {:ok, %{weblink_id: weblink_id}} -> Map.put(acc, :text_blob, weblink_id)
          {:error, _error} -> acc
        end
      _ ->
        # "recently stored"
        acc
    end
  end

  def store_text_blob(acc, _), do: acc

  def store_text_blob(acc), do: acc

  defp build_weblink_data(acc, :longtext, %PageData{text: {:ok, text, _}, headings: heading_map}) do
    # Build text in reverse -> correct order -> Join into space separated string -> trim 
    # -> cut to max length -> put in attr map
    Map.put(acc, :text, String.slice(String.trim(Enum.join(Enum.reverse([text|Enum.reduce(heading_map, [], fn {_, heading}, acc ->
      case heading do
        {:ok, text, _} -> [text|acc]
        _ -> acc
      end
    end)]), " ")), 0..@longtext_max))
  end

  defp build_weblink_data(acc, :link, %{uri: %{host: host, path: path}}) do
    Map.put(acc, :link, "#{host}#{path}")
  end

  defp build_weblink_data(acc, :samples, %PageData{samples: {:ok, samples, _}}) do
    Map.put(acc, :samples, samples)
  end

  defp build_weblink_data(acc, :description, %PageData{text: {:ok, text, _}}) do
    Map.put(acc, :description, String.slice(text, 0..@description_max))
  end

  defp build_weblink_data(acc, :title, %PageData{title: {:ok, title_text, _}}) do
    Map.put(acc, :title, String.slice(title_text, 0..@title_max))
  end

  defp build_weblink_data(acc, key, %{uri: %{host: host, path: path}} = page_data) do
    case Map.get(page_data, key) do
      {:warning, _value, msg} ->
        _ = Stats.store_link_warning("#{host}#{path}", msg)

        acc
      {:ok, _value, _msg} ->
        # TODO: unimplemented warning?
        acc
      _ ->
        acc
    end
  end
end