defmodule Zam.Schema.Image do
  use Zam.Schema.Defaults

  import Ecto.Changeset


  schema "images" do
    field :weblink_id, :integer
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:weblink_id, :url])
    |> validate_required([:weblink_id, :url], [:trim])
  end
end