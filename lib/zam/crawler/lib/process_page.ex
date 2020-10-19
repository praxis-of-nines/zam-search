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
  Normalize and clean the data, build a changeset and then add the link
  and images if valid
  """
  def store_page_data(%PageData{imgs: imgs} = page_data) do
    weblink_attr = build_weblink_data(%{}, :link, page_data)
    |> build_weblink_data(:updated_at, page_data)
    |> build_weblink_data(:samples, page_data)
    |> build_weblink_data(:description, page_data)
    |> build_weblink_data(:title, page_data)
    |> build_weblink_data(:img, page_data)
    |> build_weblink_data(:index, page_data)

    webtext_attr = build_weblink_data(%{}, :longtext, page_data)

    case Enum.empty?(weblink_attr) do
      true ->
        {:error, "no data extracted"}
      false -> 
        result = store_weblink(%{link: weblink_attr.link}, weblink_attr, imgs)
        |> store_text_blob(webtext_attr)

        {:ok, result}
    end
  end

  def store_weblink(acc, attr, imgs) do
    case QueryWeblinks.get_weblink(attr.link) do
      nil ->
        case QueryWeblinks.create_weblink(attr) do
          {:ok, %{id: weblink_id}} ->
            # Create Images
            _ = Enum.map(imgs, fn img -> 
              %{weblink_id: weblink_id, url: img}
              |> QueryWeblinks.create_image()
            end)

            Map.put(acc, :weblink, weblink_id)
          {:error, _error} ->
            IO.inspect attr
            acc
          _ ->
            acc
        end
      weblink -> 
        case QueryWeblinks.update_weblink(weblink, attr) do
          {:ok, %{id: weblink_id}} ->
            Map.put(acc, :weblink, weblink_id)
          {:error, _error} ->
            acc
        end
    end
  end

  def store_text_blob(%{:weblink => weblink_id} = acc, _attr) when is_integer(weblink_id) do
    case QueryWeblinks.get_text_blob(weblink_id) do
      nil ->
        acc
        #Disabled until fix for encoding issue
        #case QueryWeblinks.create_text_blob(Map.put(attr, :weblink_id, weblink_id)) do
        #  {:ok, %{weblink_id: weblink_id}} -> 
        #    Map.put(acc, :text_blob, weblink_id)
        #  {:error, _error} -> 
        #    acc
        #end
      _ ->
        # "recently stored"
        acc
    end
  end

  def store_text_blob(acc, _), do: acc

  def store_text_blob(acc), do: acc

  defp build_weblink_data(acc, :updated_at, %PageData{updated_at: nil}) do
    Map.put(acc, :updated_at, nil)
  end

  defp build_weblink_data(acc, :updated_at, %PageData{updated_at: updated_at}) do
    Map.put(acc, :updated_at, updated_at)
  end

  defp build_weblink_data(acc, :longtext, %PageData{text: {:ok, text, _}, headings: heading_map}) do
    # Build text in reverse -> correct order -> Join into space separated string -> trim 
    # -> cut to max length -> put in attr map
    text_final = [text|Enum.reduce(heading_map, [], fn {_, heading}, acc ->
      case heading do
        {:ok, text, _} -> [text|acc]
        _ -> acc
      end
    end)]
    |> Enum.reverse()
    |> Enum.join(" ")
    |> String.trim()
    |> String.slice(0..@longtext_max)

    Map.put(acc, :text, text_final)
  end

  defp build_weblink_data(acc, :link, %{uri: %{scheme: scheme, host: host, path: path}}) do
    cond do
      String.length("https://#{host}#{path}") < 255 ->
        Map.put(acc, :link, String.trim("https://#{host}#{path}", "/"))
      true ->
        acc
    end
  end

  defp build_weblink_data(acc, :samples, %PageData{samples: nil}), do: acc

  defp build_weblink_data(acc, :samples, %PageData{samples: samples}) do
    Map.put(acc, :samples, String.slice(String.trim(samples), 0..250))
  end

  defp build_weblink_data(acc, :index, %PageData{index: i}) do
    Map.put(acc, :index, i)
  end

  defp build_weblink_data(acc, :description, %PageData{text: text}) do
    Map.put(acc, :description, String.slice(String.trim(text), 0..@description_max))
  end

  defp build_weblink_data(acc, :title, %PageData{title: title_text}) do
    Map.put(acc, :title, String.slice(String.trim(title_text), 0..@title_max))
  end

  defp build_weblink_data(acc, :img, %PageData{img: nil}), do: acc

  defp build_weblink_data(acc, :img, %PageData{img: img_src}) do
    Map.put(acc, :img, String.trim(img_src))
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