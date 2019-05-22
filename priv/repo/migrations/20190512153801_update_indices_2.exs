defmodule Zam.Repo.Migrations.UpdateIndices2 do
  use Ecto.Migration

  def change do
    alter table(:indices) do
      remove :depth

      add :depth, :smallint
    end
  end
end
