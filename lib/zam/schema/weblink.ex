defmodule Zam.Schema.Weblink do
  use Zam.Schema.Defaults

  import Ecto.Changeset


  schema "weblinks" do
    field :title, :string
    field :link, :string
    field :img, :string
    field :description, :string, default: ""
    field :samples, :string, default: ""
    field :amt_crawled, :integer, default: 1
    field :score_link, :integer, default: 0
    field :score_zam, :integer, default: 1
    field :index, :integer

    timestamps()
  end

  @doc false
  def changeset(weblink, attrs) do
    weblink
    |> cast(attrs, [:title, :link, :img, :description, :samples, :amt_crawled, :score_link, :score_zam, :index])
    |> validate_required([:title, :link], [:trim])
  end
end