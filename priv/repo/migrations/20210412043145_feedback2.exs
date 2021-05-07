defmodule Zam.Repo.Migrations.Feedback2 do
  use Ecto.Migration

  def change do
    create table(:feedback) do
      add :domain, :string
      add :bad_search, :string
      add :report_domain, :string
      add :comment, :string
     
      timestamps()
    end
  end
end
