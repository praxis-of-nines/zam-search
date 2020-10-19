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
    field :updated_at, :naive_datetime
    field :inserted_at, :naive_datetime
  end

  @doc false
  def changeset(weblink, %{inserted_at: _, updated_at: updated_at} = attrs) do
    updated_at = case updated_at do
      nil -> Timex.shift(DateTime.utc_now(), days: -60) 
      updated_at -> updated_at
    end

    attrs = Map.put(attrs, :updated_at, updated_at)

    weblink
    |> cast(attrs, [
      :title, 
      :link, 
      :img, 
      :description, 
      :samples, 
      :amt_crawled, 
      :score_link, 
      :score_zam, 
      :index,
      :inserted_at,
      :updated_at])
    |> validate_required([:title, :link, :inserted_at, :updated_at], [:trim])
  end

  def changeset(index, attrs) do
    attrs = Map.put(attrs, :inserted_at, DateTime.utc_now())
    changeset(index, attrs)
  end
end