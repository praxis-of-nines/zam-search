defmodule Zam.Repo.Migrations.Weblinks do
  use Ecto.Migration

  def change do
    create table(:weblinks) do
      add :title, :string
      add :link, :string
      add :description, :string
      add :samples, :string
      add :amt_crawled, :integer
      add :score_link, :integer
      add :score_zam, :integer
     
      timestamps()
    end

    create index(:weblinks, [:link])
  end
end
