defmodule Zam.Repo.Migrations.Definitions do
  use Ecto.Migration

  def change do
    create table(:definitions) do
      add :title, :string
      add :description, :string
     
      timestamps()
    end

    create table(:bookmarks) do
      add :domain_id, :integer
      add :bookmark_link, :string
     
      timestamps()
    end
  end
end
