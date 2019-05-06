defmodule Zam.Crawler do
  alias Flow

  alias Zam.Crawler.Robots


  @doc """
  Crawl a single domain as well as boot up the standard tracking process to monitor
  crawl progress
  """
  def crawl(url) do
    _ = :ets.new(:crawler_counts, [:named_table, :public])

    rules = Robots.parse_from(url <> "/robots.txt")

    options = build_options(url, %{}, rules)
    
    {_stats_ref, results} = Crawlie.crawl_and_track_stats(
      [url],
      Zam.Crawler.ParserLogic,
      options)

    #_stats_printing_task = Task.async(fn -> periodically_dump_stats(stats_ref) end)

    #Task.await(stats_printing_task)

    IO.inspect "DONE!"    

    poy = results
    |> Enum.to_list()

    IO.inspect poy
    IO.inspect "I MEAN>>> DONE@!"
    poy
  end

  # TODO: Move to channel and allow subscription to updates / Also would store updates in database
  def periodically_dump_stats(ref) do
    stats = Crawlie.Stats.Server.get_stats(ref)
    
    IO.puts "STATS AFTER #{Crawlie.Stats.Server.Data.elapsed_usec(stats) / 1_000_000} SECONDS"
    
    IO.inspect(stats.status_codes_dist)
    
    IO.inspect(:ets.lookup(:crawler_counts, :price_total))
    IO.inspect(:ets.lookup(:crawler_counts, :items_found))
    IO.inspect(:ets.lookup(:crawler_counts, :pages_parsed))
    IO.puts ""
    if Crawlie.Stats.Server.Data.finished?(stats) do
      :ok
    else
      Process.sleep(4000)
      periodically_dump_stats(ref)
    end
  end

  defp build_options(url, %{} = _index, rules) do
    domain = case url do
      "https://" <> domain -> domain
      "http://" <> domain -> domain
      domain -> domain
    end

    [
      max_depth: 1,
      min_demand: 1,
      max_demand: 5,
      fetch_phase: [
        stages: 20,
        min_demand: 1,
        max_demand: 5,
      ],
      process_phase: [
        stages: 8,
        min_demand: 5,
        max_demand: 10,
      ],
      domain: domain,
      bot_rules: rules
    ]
  end
end