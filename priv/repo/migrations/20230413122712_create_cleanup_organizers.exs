defmodule Trashy.Repo.Migrations.CreateCleanupOrganizers do
  use Ecto.Migration

  def change do
    create table(:cleanup_organizers) do
      add :cleanup_id, references(:cleanups, on_delete: :nothing)
      add :organizer_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:cleanup_organizers, [:cleanup_id])
    create index(:cleanup_organizers, [:organizer_id])
  end
end
