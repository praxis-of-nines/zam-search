defmodule Mix.Tasks.Zam.Create.Index do
  @moduledoc """
  Create an index record (record indicating you want to run an index when indexing :all). Note you need
  the web domain id currently.  Provide the depth (how many links deep to follow ie link of a link etc),
  the interval at which to crawl (acceptable intervals: daily, monthly, hourly, weekly) and whether it is
  an active index (scheduler picks it up; acceptable values are 1 and 0). Note that interval cache is not
  yet used.

  ## Example

    # Create an index for domain id 1 with depth 2 that runs weekly and is active
    iex> mix zam.create.index 1 2 weekly 1
  """
  use Mix.Task

  alias Zam.Schema.{QueryWeblinks}
  
  @shortdoc "Create an index record, the index rules for a domain"


  def run([domain_id, depth, interval, active]) do
    Mix.Task.run("app.start")

    Mix.shell.info "Creating #{interval} index"

    index = %{
      webdomain_id: domain_id,
      depth: depth,
      interval_index: interval,
      active: active
    }

    case QueryWeblinks.create_index(index) do
      {:ok, %{id: id}} -> Mix.shell.info "Created Successfully (#{id})"
      {:error, error} -> IO.puts error
    end
  end

  def run(_), do: Mix.shell.info "Must provide [webdomain_id, depth, interval, active] arguments"
end