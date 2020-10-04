defmodule Zam.Repo.Migrations.WeblinksIndex do
  use Ecto.Migration

  def change do
    alter table(:weblinks) do
      add :index, :bigint
    end
  end
end
