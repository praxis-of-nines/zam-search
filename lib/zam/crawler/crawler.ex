defmodule Zam.Crawler do
  @moduledoc """
  The Zam Crawler: Designed for each process crawling root to handle one domain each.  Respects
  robots.txt and avoids links out to other domains
  """
  alias Flow

  alias Zam.Crawler.Robots
  alias Zam.Crawler.Stats

  alias Zam.Crawler.ProcessPage
  alias Zam.Schema.{QueryWeblinks, Webdomain}


  @doc """
  Crawl a single or list of domains as well as boot up the standard tracking process to monitor
  crawl progress
  """
  def crawl(:all), do: crawl_async(QueryWeblinks.get_indices(:all))
  def crawl(:daily), do: crawl_async(QueryWeblinks.get_indices("daily"))
  def crawl(:hourly), do: crawl_async(QueryWeblinks.get_indices("hourly"))
  def crawl(:weekly), do: crawl_async(QueryWeblinks.get_indices("weekly"))
  def crawl(:monthly), do: crawl_async(QueryWeblinks.get_indices("monthly"))

  def crawl(url) when is_binary(url) do
    %Webdomain{id: id} = QueryWeblinks.get_webdomain(url)

    index = QueryWeblinks.get_index(id)

    crawl(url, index)
  end

  def crawl(_) do
    IO.puts "Invalid Index or URL provided to crawl method"
  end

  def crawl(url, index) when is_binary(url) do
    rules = case Robots.parse_from(url <> "/robots.txt") do
      {:ok, rules} -> rules
      {:error, _reason} -> []
    end

    options = build_options(url, index, rules)
    
    {stats_ref, results} = Crawlie.crawl_and_track_stats(
      [url],
      Zam.Crawler.ParserLogic,
      options)

    _stats_printing_task = Task.async(fn -> periodically_dump_stats(Keyword.get(options, :domain), stats_ref) end)    

    result_count = results
    |> Flow.reduce(fn () -> [] end, &store_page/2)
    |> Enum.count()

    result_count
  end

  defp store_page(page_data, list_acc) do
    case ProcessPage.store_page_data(page_data) do
      {:ok, %{:weblink => weblink_id}} -> 
        [weblink_id|list_acc]
      {:ok, %{}} ->
        list_acc
      {:error, _} -> 
        list_acc
    end
  end

  @doc """
  Periodically check the stats to see if we are finished crawling
  """
  def periodically_dump_stats(domain, ref) do
    stats = Crawlie.Stats.Server.get_stats(ref)
    
    if Crawlie.Stats.Server.Data.finished?(stats) do
      Stats.store_responses(domain, stats.status_codes_dist)

      :ok
    else
      Process.sleep(10000)
      periodically_dump_stats(domain, ref)
    end
  end

  defp crawl_async(indices) do
    crawl_tasks = Enum.reduce(indices, [], fn %{index: i, webdomain: %{domain: domain}}, acc ->
      [Task.async(fn -> crawl(domain, i) end)|acc]
    end)

    Enum.map(crawl_tasks, fn crawl_task -> Task.await(crawl_task, :infinity) end)
  end

  defp build_options(url, %{depth: depth} = _index, rules) do
    domain = case url do
      "https://" <> domain -> domain
      "http://" <> domain -> domain
      domain -> domain
    end

    crawl_interval = Keyword.get(rules, :delay_seconds, 0)

    max_visits = get_option_max_visits(crawl_interval)

    {stages, min_demand, max_demand} = get_option_fetch_phase(max_visits)

    [
      max_depth: depth,
      min_demand: 1,
      max_demand: 5,
      max_visits: max_visits,
      interval: crawl_interval * 1000, # Crawlie counts miliseconds
      fetch_phase: [
        stages: stages,
        min_demand: min_demand,
        max_demand: max_demand,
      ],
      process_phase: [
        stages: 20,
        min_demand: 1,
        max_demand: 20,
      ],
      domain: domain,
      headers: [{"User-agent", Application.get_env(:zam, :user_agent)}],
      bot_rules: rules
    ]
  end

  # Currently set to avoid runs longer than 2~ hours (for the most part)
  # when a delay is requested (TODO: move these somewhere where they can be controlled
  # visibly)
  defp get_option_max_visits(1), do: 10000
  defp get_option_max_visits(10), do: 720 # use 360 if interval working correctly
  defp get_option_max_visits(0), do: 20000
  defp get_option_max_visits(integer) when integer < 10, do: 2000
  defp get_option_max_visits(_integer), do: 2000

  # Flow settings for crawler: {Stages, Min Demand, Max Demand}
  defp get_option_fetch_phase(0), do: {20, 1, 30}
  defp get_option_fetch_phase(_), do: {1, 1, 2}
end