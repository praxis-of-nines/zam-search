defmodule Zam.ReleaseTasks do
  @moduledoc """
  Run tasks related to new or migrating systems
  """
  import Ecto.Query, warn: false

  def myapp, do: Application.get_application(__MODULE__)

  def repos, do: Application.get_env(myapp(), :ecto_repos, [])

  alias Zam.Schema.QueryWeblinks


  @doc """
  Migrate Database
  """
  def migrate([]) do
    start_app()

    path = Application.app_dir(:zam, "priv/repo/migrations")

    Ecto.Migrator.run(Zam.Repo, path, :up, all: true)

    stop_app()
  end

  def crawl(["all"]) do
    start_app()

    IO.puts "Attempting to crawl all active URL's"

    {:ok, _started} = Application.ensure_all_started(:crawlie)

    _results = Zam.Crawler.crawl(:all)

    IO.puts "Finished crawling everything!"

    stop_app()
  end

  def crawl([url]) do
    start_app()

    IO.puts "Attempting to crawl starting at: #{url}"

    {:ok, _started} = Application.ensure_all_started(:crawlie)

    _results = Zam.Crawler.crawl(url)

    IO.puts "Finished crawling #{url}!"

    stop_app()
  end

  def create_domain([domain]) do
    start_app()

    IO.puts "Creating Domain #{domain}"

    webdomain = %{domain: String.trim(domain, "/")}

    case QueryWeblinks.create_webdomain(webdomain) do
      {:ok, %{id: id}} ->IO.puts "Created Successfully (#{id})"
      {:error, error} -> IO.puts error
    end

    stop_app()
  end

  def create_index([domain_id, depth, interval, active]) do
    start_app()

    IO.puts "Creating #{interval} index"

    index = %{
      webdomain_id: domain_id,
      depth: depth,
      interval_index: interval,
      active: active
    }

    case QueryWeblinks.create_index(index) do
      {:ok, %{id: id}} -> IO.puts "Created Successfully (#{id})"
      {:error, error} -> IO.puts error
    end

    stop_app()
  end

  def create_definition([title, description, example]) do
    start_app()

    IO.puts "Creating definition for #{title}"

    definition = %{title: title, description: description, example: example}

    case QueryWeblinks.create_definition(definition) do
      {:ok, %{id: id}} -> IO.puts "Created Successfully (#{id})"
      {:error, error} -> IO.puts error
    end

    stop_app()
  end

  def create_link([title, link, description, samples]) do
    start_app()

    IO.puts "Creating Link #{title} | #{link} | #{description} | #{samples}"

    link = %{title: title, link: link, description: description, samples: samples}

    case QueryWeblinks.create_weblink(link) do
      {:ok, %{id: id}} -> IO.puts "Created Successfully (#{id})"
      {:error, error} -> IO.puts error
    end

    stop_app()
  end

  def priv_dir(app), do: "#{:code.priv_dir(app)}"

  defp start_app() do
    IO.puts "Starting dependencies.."

    {:ok, _} = Application.ensure_all_started(:zam)

    _ = Application.ensure_all_started(:timex)
  end

  defp stop_app() do
    :init.stop()
  end
end