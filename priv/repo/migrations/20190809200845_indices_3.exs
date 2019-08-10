defmodule Zam.Repo.Migrations.Indices3 do
  use Ecto.Migration

  def change do
    create index(:bookmarks, [:domain_id])
  end
end
