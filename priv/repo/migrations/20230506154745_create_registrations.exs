defmodule Trashy.Repo.Migrations.CreateRegistrations do
  use Ecto.Migration

  def change do
    create table(:registrations) do
      add :name, :string
      add :email, :string
      add :cleanup_id, references(:cleanups, on_delete: :nothing)

      timestamps()
    end

    create index(:registrations, [:cleanup_id])
  end
end
