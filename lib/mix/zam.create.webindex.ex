defmodule Mix.Tasks.Zam.Create.Webindex do
  @moduledoc """
  Create a webdomain manually using the provided domain.

  ## Example

    iex> mix zam.create.domain "https://yams4u.com"
  """
  use Mix.Task

  alias Zam.Schema.{QueryWeblinks, Webdomain}
  
  @shortdoc "Create a webdomain manually using the provided domain"


  def run([domain]) do
    Mix.Task.run("app.start")

    Mix.shell.info "Creating Domain #{domain}"

    webdomain = %Webdomain{domain: String.trim(domain, "/")}

    case QueryWeblinks.create_webdomain(webdomain) do
      {:ok, %{id: id}} -> Mix.shell.info "Created Successfully (#{id})"
      {:error, error} -> IO.puts error
    end
  end

  def run(_), do: Mix.shell.info "Must provide [domain] arguments"
end