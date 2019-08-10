defmodule Zam.Repo.Migrations.Definitions3 do
  use Ecto.Migration

  def change do
    alter table(:definitions) do
      remove :example

      add :example, :text
    end
  end
end
