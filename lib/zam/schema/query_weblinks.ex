defmodule Zam.Schema.QueryWeblinks do
  @moduledoc """
  Query the websites table
  """
  import Ecto.Query, warn: false
  alias Zam.Repo

  alias Zam.Schema.{Weblink, Webdomain, TextBlob}


  # Retrievals
  def get_weblink(link), do: Repo.get_by(Weblink, link: link)
  def get_text_blob(weblink_id), do: Repo.get_by(TextBlob, weblink_id: weblink_id)

  # Creations
  def create_weblink(%{} = attrs), do: %Weblink{} |> Weblink.changeset(attrs) |> Repo.insert()
  def create_webdomain(%{} = attrs), do: %Webdomain{} |> Webdomain.changeset(attrs) |> Repo.insert()
  def create_text_blob(%{} = attrs), do: %TextBlob{} |> TextBlob.changeset(attrs) |> Repo.insert()

  # Updates
  def update_weblink(%Weblink{} = weblink, attrs) do 
    weblink 
    |> Weblink.changeset(attrs) 
    |> Repo.update()
  end

  def update_webdomain(%Webdomain{} = webdomain, attrs) do 
    webdomain
    |> Webdomain.changeset(attrs) 
    |> Repo.update()
  end
end
