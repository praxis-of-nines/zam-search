defmodule Zam.Repo.Migrations.ResponseLog do
  use Ecto.Migration

  def change do
    create table(:response_log) do
      add :code, :string
      add :referrer, :string
      add :uri, :string
     
      timestamps()
    end

    create index(:response_log, [:code])
    create index(:response_log, [:referrer])
  end
end
