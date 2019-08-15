defmodule Zam.Schema.ResponseLog do
  use Zam.Schema.Defaults

  import Ecto.Changeset


  schema "response_log" do
    field :code, :string
    field :referrer, :string
    field :uri, :string
    
    timestamps()
  end

  @doc false
  def changeset(response_log, attrs) do
    response_log
    |> cast(attrs, [:code, :referrer, :uri])
    |> validate_required([:code, :uri])
  end
end
