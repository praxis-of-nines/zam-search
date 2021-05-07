defmodule Zam.Repo.Migrations.Feedback3 do
  use Ecto.Migration

  def change do
    alter table(:feedback) do
        add :ip, :string
    end
  end
end
