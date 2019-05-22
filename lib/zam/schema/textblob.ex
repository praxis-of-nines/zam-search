defmodule Zam.Schema.TextBlob do
  use Zam.Schema.Defaults

  import Ecto.Changeset


  schema "text_blobs" do
    field :weblink_id, :integer
    field :text, :binary

    timestamps()
  end

  @doc false
  def changeset(text_blobs, attrs) do
    text_blobs
    |> cast(attrs, [:weblink_id, :text])
    |> validate_required([:weblink_id, :text], [:trim])
  end
end
