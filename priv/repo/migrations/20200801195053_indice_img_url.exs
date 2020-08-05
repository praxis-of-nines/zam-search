defmodule Zam.Repo.Migrations.IndiceImgUrl do
  use Ecto.Migration

  def change do
    alter table(:weblinks) do
      add :img, :string
    end
  end
end
