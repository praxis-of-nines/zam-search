defmodule SimpleStatEx.Repo.Migrations.CreateSimplestats do
  @moduledoc false
  use Ecto.Migration

  def change do
    create_if_not_exists table(:simplestats) do
      add :category, :string
      add :period, :string
      add :time, :naive_datetime
      add :count, :integer

      timestamps()
    end
    create_if_not_exists unique_index(:simplestats, [:category, :time])
    create_if_not_exists index(:simplestats, [:period])

  end
end