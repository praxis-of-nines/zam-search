defmodule Zam.Repo.Migrations.WeblinksContent do
  use Ecto.Migration

  def change do
    alter table(:indices) do
      add :content, :string
    end
  end
end