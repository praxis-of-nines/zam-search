defmodule Zam.Crawler.Stats do
  @moduledoc """
  Store stats related to crawling activity and issues
  """
  #alias SimpleStatEx, as: SSX

  @doc """
  Store statistics for all the page responses gathered thus far
  """
  def store_responses(_domain, response_map) do
    Enum.each(response_map, fn {_code, _amount} ->
      #_code = Integer.to_string(code)

      #SSX.stat("crawl #{code} #{domain}", :daily, amount) |> SSX.save()
      :ok
    end)
  end

  def store_link_warning(_domain, _msg) do
    #SSX.stat("warning #{domain}: #{msg}", :daily) |> SSX.save()
    :ok
  end
end