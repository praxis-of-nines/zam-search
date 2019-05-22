defmodule Zam.Repo.Migrations.UriTableName do
  use Ecto.Migration

  def change do
    drop table (:weburis)

    create table(:webdomains) do
      add :domain, :string
      add :score_link, :integer
      add :score_zam, :integer
     
      timestamps()
    end
  end
end
