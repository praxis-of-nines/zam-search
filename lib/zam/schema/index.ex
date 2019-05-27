defmodule Zam.Schema.Index do
  use Zam.Schema.Defaults

  import Ecto.Changeset


  schema "indices" do
    field :webdomain_id, :integer
    field :depth, :integer
    field :interval_index, :string
    field :interval_cache, :string
    field :active, :integer
    
    timestamps()
  end

  @doc false
  def changeset(index, attrs) do
    index
    |> cast(attrs, [:webdomain_id, :depth, :interval_index, :interval_cache, :active])
    |> validate_required([:webdomain_id, :depth, :active, :interval_index])
  end
end
