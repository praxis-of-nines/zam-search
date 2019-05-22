defmodule SimpleStatEx.Repo.Migrations.CreateSimplestats do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:simplestats) do
      add :category, :string
      add :period, :string
      add :time, :naive_datetime
      add :count, :integer

      timestamps()
    end
    create unique_index(:simplestats, [:category, :time])
    create index(:simplestats, [:period])

  end
end