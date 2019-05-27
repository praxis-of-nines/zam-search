defmodule Mix.Tasks.Zam.Crawler.Crawl do
  @moduledoc """
  Manually order to crawl a single webpage using default settings or a grouping of pages. Note that
  this is mainly for testing or seeding your site, as your scheduler will run the indexes in production.

  ## Example

    iex> mix zam.crawler.crawl "https://www.infogalactic.com"
  """
  use Mix.Task
  
  @shortdoc "Manually order to crawl a single webpage using default settings"

  def run(["all"]) do
    Mix.Task.run("app.start")

    Mix.shell.info "Attempting to crawl all active URL's"

    {:ok, _started} = Application.ensure_all_started(:crawlie)

    _results = Zam.Crawler.crawl(:all)

    IO.inspect "Finished crawling everything!"
  end

  def run([url]) do
    Mix.Task.run("app.start")

    Mix.shell.info "Attempting to crawl starting at: #{url}"

    {:ok, _started} = Application.ensure_all_started(:crawlie)

    _results = Zam.Crawler.crawl(url)

    IO.inspect "Finished crawling #{url}!"
  end

  def run(_), do: Mix.shell.info "Must provide url argument"
end