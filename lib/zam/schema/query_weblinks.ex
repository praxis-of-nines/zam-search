defmodule Zam.Schema.QueryWeblinks do
  @moduledoc """
  Query the websites table
  """
  import Ecto.Query, warn: false
  alias Zam.Repo

  alias Zam.Schema.Weblink


  def get_weblink(link), do: Repo.get_by(Weblink, link: link)

  def create_weblink(%Weblink{} = weblink), do: weblink |> Repo.insert()

  def update_weblink(%Weblink{} = weblink, attrs), do: weblink 
    |> Weblink.changeset(attrs) 
    |> Repo.update()
end