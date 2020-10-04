defmodule Zam.Repo.Migrations.MoreIndexMeta do
  use Ecto.Migration

  def change do
    alter table(:indices) do
      add :image_i, :smallint, default: 1
      add :tags, :string
    end
  end
end
