defmodule Zam.Crawler do
  @moduledoc """
  The Zam Crawler: 
  Spawns crawling processes for each scheduled domain
  """
  alias Flow

  alias Zam.Crawler.Robots
  alias Zam.Crawler.Stats

  alias Zam.Crawler.ProcessPage
  alias Zam.Schema.{QueryWeblinks, Webdomain}

  @doc """
  Crawl a single or list of domains as well as boot up the standard tracking process to monitor
  crawl progress
  NOTE: with crawlie 1.0.0 probably can avoid needing async crawl tasks
  """
  def crawl(:all), do: crawl_async(QueryWeblinks.get_indices(:all))
  def crawl(:test), do: crawl_async(QueryWeblinks.get_indices("test"))
  def crawl(:test2), do: crawl_async(QueryWeblinks.get_indices("test2"))
  def crawl(:daily) do
    IO.puts("Running Daily Index")
    crawl_async(QueryWeblinks.get_indices("daily"))
  end
  def crawl(:hourly) do 
    IO.puts("Running Hourly Index")
    crawl_async(QueryWeblinks.get_indices("hourly"))
  end
  def crawl(:weekly) do
    IO.puts("Running Weekly Index")
    crawl_async(QueryWeblinks.get_indices("weekly"))
  end
  def crawl(:monthly) do
    IO.puts("Running Monthly Index")
    crawl_async(QueryWeblinks.get_indices("monthly"))
  end

  def crawl(url) when is_binary(url) do
    case QueryWeblinks.get_webdomain(url) do
      %Webdomain{id: id} ->
        index = QueryWeblinks.get_index(id)

        crawl(id, url, index)
      _ ->
        IO.puts "Invalid URL, no webdomain record found"
    end

    
  end

  def crawl(_) do
    IO.puts "Invalid Index or URL provided to crawl method"
  end

  def crawl(webdomain_id, url, index) when is_binary(url) do
    %URI{host: host, scheme: scheme} = URI.parse(url)

    url_robots =  "#{scheme}://#{host}/robots.txt" 

    # Note: crawlie 1.0 claims to respect robots. May be able to take out
    rules = case Robots.parse_from(url_robots) do
      {:ok, rules} -> rules
      {:error, _reason} -> []
    end

    options = build_options(url, index, rules)

    crawl_urls = case QueryWeblinks.get_bookmark(webdomain_id) do
      %{bookmark_link: bookmark_url} -> [url, bookmark_url]
      _ -> [url]
    end
    
    {stats_ref, results} = Crawlie.crawl_and_track_stats(
      crawl_urls,
      Zam.Crawler.ParserLogic,
      options)

    _stats_printing_task = Task.async(fn -> periodically_dump_stats(Keyword.get(options, :domain), stats_ref) end)    

    results = results
    |> Flow.reduce(fn () -> [] end, &store_page/2)
    |> Enum.reverse()

    case length(results) do
      0 -> 
        0
      length -> 
        _ = QueryWeblinks.create_bookmark(%{domain_id: webdomain_id, bookmark_link: List.first(results)})
        length
    end
  end

  defp store_page(page_data, list_acc) do
    case ProcessPage.store_page_data(page_data) do
      {:ok, %{:link => link}} -> 
        [link|list_acc]
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
    crawl_tasks = Enum.reduce(indices, [], fn %{index: i, webdomain: %{id: id, domain: domain}}, acc ->
      IO.inspect("Crawling #{id}:${domain}")
      [Task.async(fn -> crawl(id, domain, i) end)|acc]
    end)

    Enum.map(crawl_tasks, fn crawl_task -> 
      Task.await(crawl_task, :infinity)
      IO.inspect "Finished a crawl"
    end)
  end

  defp build_options(url, %{index: index}, rules), do: build_options(url, index, rules)

  defp build_options(url, %{id: id, depth: depth, image_i: image_i, content: content} = _index, rules) do
    domain = case url do
      "https://" <> domain -> domain
      "http://" <> domain -> domain
      domain -> domain
    end

    crawl_interval = Keyword.get(rules, :delay_seconds, 0)

    max_visits = get_option_max_visits(crawl_interval)

    {stages, min_demand, max_demand} = get_option_fetch_phase(max_visits)

    [
      index_id: id,
      max_depth: depth,
      image_i: image_i,
      content: content,
      min_demand: 1,
      max_demand: 50,
      max_visits: max_visits,
      interval: max(1, crawl_interval * 1000), # Crawlie counts miliseconds
      fetch_phase: [
        stages: stages,
        min_demand: min_demand,
        max_demand: max_demand,
      ],
      process_phase: [
        stages: 3,
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
  # visibly, conf seems better)
  defp get_option_max_visits(1), do: 30000
  defp get_option_max_visits(10), do: 20000
  defp get_option_max_visits(0), do: 200000
  defp get_option_max_visits(integer) when integer < 10, do: 30000
  defp get_option_max_visits(_integer), do: 30000

  # Flow settings for crawler: {Stages, Min Demand, Max Demand}
  defp get_option_fetch_phase(_), do: {3, 1, 20}
end