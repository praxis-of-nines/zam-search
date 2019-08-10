defmodule Zam.Schema.Bookmark do
  use Zam.Schema.Defaults

  import Ecto.Changeset


  schema "bookmarks" do
    field :domain_id, :integer
    field :bookmark_link, :string

    timestamps()
  end

  @doc false
  def changeset(bookmark, attrs) do
    bookmark
    |> cast(attrs, [:domain_id, :bookmark_link])
    |> validate_required([:domain_id, :bookmark_link], [:trim])
  end
end