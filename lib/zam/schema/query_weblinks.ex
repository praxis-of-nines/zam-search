defmodule Zam.Schema.QueryWeblinks do
  @moduledoc """
  Query Zam tables
  """
  import Ecto.Query, warn: false
  alias Zam.Repo

  alias Zam.Schema.{Weblink, Index, Webdomain, TextBlob, Definition, Bookmark}


  # Retrievals
  def get_weblink(link), do: Repo.get_by(Weblink, link: link)
  def get_webdomain(domain), do: Repo.get_by(Webdomain, domain: domain)
  def get_text_blob(weblink_id), do: Repo.get_by(TextBlob, weblink_id: weblink_id)
  def get_bookmark(domain_id), do: Repo.get_by(Bookmark, domain_id: domain_id)

  def get_indices(:all) do
    Index
    |> Ecto.Query.join(:inner, [i], w in Webdomain, on: i.webdomain_id == w.id)
    |> Ecto.Query.select([i, w], %{:index => i, :webdomain => w})
    |> Ecto.Query.where([i], i.active == 1)
    |> Repo.all()
  end

  def get_indices(interval) when is_binary(interval) do
    Index
    |> Ecto.Query.join(:inner, [i], w in Webdomain, on: i.webdomain_id == w.id)
    |> Ecto.Query.where(interval_index: ^interval)
    |> Ecto.Query.where([i], i.active == 1)
    |> Ecto.Query.select([i, w], %{:index => i, :webdomain => w})
    |> Repo.all()
  end

  def get_index(webdomain_id) when is_integer(webdomain_id) do
    Index
    |> Ecto.Query.join(:inner, [i], w in Webdomain, on: i.webdomain_id == w.id)
    |> Ecto.Query.select([i, w], %{:index => i, :webdomain => w})
    |> Repo.get_by(webdomain_id: webdomain_id)
  end

  # Creations
  def create_weblink(%{} = attrs), do: %Weblink{} |> Weblink.changeset(attrs) |> Repo.insert()
  def create_index(%{} = attrs), do: %Index{} |> Index.changeset(attrs) |> Repo.insert()
  def create_webdomain(%{} = attrs), do: %Webdomain{} |> Webdomain.changeset(attrs) |> Repo.insert()
  def create_text_blob(%{} = attrs), do: %TextBlob{} |> TextBlob.changeset(attrs) |> Repo.insert()
  def create_definition(%{} = attrs), do: %Definition{} |> Definition.changeset(attrs) |> Repo.insert()
  def create_bookmark(%{} = attrs), do: %Bookmark{} |> Bookmark.changeset(attrs) |> Repo.insert()

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
