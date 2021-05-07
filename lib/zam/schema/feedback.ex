defmodule Zam.Schema.Feedback do
  use Zam.Schema.Defaults

  import Ecto.Changeset


  schema "feedback" do
    field :ip, :string
    field :domain, :string
    field :report_domain, :string
    field :bad_search, :string
    field :comment

    timestamps()
  end

  @doc false
  def changeset(definition, attrs) do
    definition
    |> cast(attrs, [:ip, :domain, :report_domain, :bad_search, :comment])
    |> validate_required([:ip], [:trim])
  end
end