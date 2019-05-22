defmodule Zam.Repo.Migrations.AlterWeb do
  use Ecto.Migration

  def change do
    alter table(:webnotes) do
      remove :weburi_id

      add :webdomain_id, :bigint
    end

    create index(:webnotes, [:webdomain_id, :note])
    create unique_index(:webdomains, [:domain])
  end
end