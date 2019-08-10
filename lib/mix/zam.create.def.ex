defmodule Mix.Tasks.Zam.Create.Def do
  @moduledoc """
  Create a definition manually using the provided title/description

  ## Example

    iex> mix zam.create.def "inch" "a unit of measurement"
  """
  use Mix.Task

  alias Zam.Schema.{QueryWeblinks}
  
  @shortdoc "Create a definition manually using the provided title/description"


  def run([title, description, example]) do
    Mix.Task.run("app.start")

    Mix.shell.info "Creating Definition #{title} #{description} #{example}"

    definition = %{title: String.trim(title), description: String.trim(description), example: String.trim(example)}

    case QueryWeblinks.create_definition(definition) do
      {:ok, %{id: id}} -> Mix.shell.info "Created Successfully (#{id})"
      {:error, error} -> IO.puts error
    end
  end

  def run(_), do: Mix.shell.info "Must provide [title, description] arguments"
end