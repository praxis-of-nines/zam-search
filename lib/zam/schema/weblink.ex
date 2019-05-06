defmodule Zam.Schema.Weblink do
  use Zam.Schema.Defaults

  import Ecto.Changeset


  schema "weblinks" do
    field :title, :string
    field :link, :string
    field :description, :string
    field :samples, :string
    field :amt_crawled, :integer, default: 1
    field :score_link, :integer, default: 0
    field :score_zam, :integer, default: 1

    timestamps()
  end

  @doc false
  def changeset(weblink, attrs) do
    weblink
    |> cast(attrs, [:title, :link, :description, :samples, :amt_crawled, :score_link, :score_zam])
    |> validate_required([:title, :link, :description, :samples], [:trim])
  end
end