defmodule Zam.Repo.Migrations.AddImages do
  use Ecto.Migration

  def change do
    create table(:images) do
      add :weblink_id, :bigint
      add :url, :string
     
      timestamps()
    end
  end
end
