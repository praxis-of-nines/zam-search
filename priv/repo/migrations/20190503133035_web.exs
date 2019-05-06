defmodule Zam.Repo.Migrations.Web do
  use Ecto.Migration

  def change do
    create table(:text_blobs) do
      add :weblink_id, :bigint
      add :text, :text
     
      timestamps()
    end

    create index(:text_blobs, [:weblink_id])

    create table(:weburis) do
      add :uri, :string
      add :score_link, :integer
      add :score_zam, :integer
     
      timestamps()
    end

    create unique_index(:weburis, [:uri])

    create table(:webnotes) do
      add :weburi_id, :bigint
      add :note, :string

      timestamps()
    end

    create index(:webnotes, [:weburi_id, :note])
  end
end
