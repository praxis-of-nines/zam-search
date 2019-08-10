defmodule Zam.Schema.Definition do
  use Zam.Schema.Defaults

  import Ecto.Changeset


  schema "definitions" do
    field :title, :string
    field :description, :string
    field :example, :string

    timestamps()
  end

  @doc false
  def changeset(definition, attrs) do
    definition
    |> cast(attrs, [:title, :description, :example])
    |> validate_required([:title, :description, :example], [:trim])
  end
end