defmodule Zam.Repo.Migrations.Definitions2 do
  use Ecto.Migration

  def change do
    alter table(:definitions) do
      add :example, :string
    end
  end
end
