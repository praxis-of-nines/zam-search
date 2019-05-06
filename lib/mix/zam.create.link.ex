defmodule Mix.Tasks.Zam.Create.Link do
  @moduledoc """
  Create a weblink manually using the provided arguments.

  ## Example

    iex> mix zam.create.link "TestSite: purveyors of yams" "https://yams4u.com" "Yam is great yes" "yam hotel rider yam heaven"
  """
  use Mix.Task

  alias Zam.Schema.{QueryWeblinks, Weblink}
  
  @shortdoc "Create a weblink manually using the provided arguments"


  def run([title, link, description, samples]) do
    Mix.Task.run("app.start")

    Mix.shell.info "Creating Link #{title} | #{link} | #{description} | #{samples}"

    link = %Weblink{title: title, link: link, description: description, samples: samples}

    case QueryWeblinks.create_weblink(link) do
      {:ok, %{id: id}} -> Mix.shell.info "Created Successfully (#{id})"
      {:error, error} -> IO.puts error
    end
  end

  def run(_), do: Mix.shell.info "Must provide [title , link , description , samples] arguments"
end