defmodule Zam.Schema.Webdomain do
  use Zam.Schema.Defaults

  import Ecto.Changeset


  schema "webdomains" do
    field :domain, :string
    field :score_link, :integer, default: 0
    field :score_zam, :integer, default: 1

    timestamps()
  end

  @doc false
  def changeset(webdomain, attrs) do
    webdomain
    |> cast(attrs, [:domain, :score_link, :score_zam])
    |> validate_required([:domain], [:trim])
  end
end