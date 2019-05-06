defmodule Zam.Repo.Migrations.Indices do
  use Ecto.Migration

  def change do
    create table(:indices) do
      add :weburi_id, :bigint
      add :depth, :string
      add :interval_index, :string
      add :interval_cache, :string
      add :active, :smallint
     
      timestamps()
    end

    create index(:indices, [:weburi_id])
    create index(:indices, [:active])
  end
end
