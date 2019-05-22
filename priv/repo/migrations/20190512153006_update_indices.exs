defmodule Zam.Repo.Migrations.UpdateIndices do
  use Ecto.Migration

  def change do
    alter table(:indices) do
      remove :weburi_id

      add :webdomain_id, :bigint
    end

    create index(:indices, [:webdomain_id])
  end
end