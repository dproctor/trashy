defmodule Trashy.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :time, :utc_datetime
      add :cleanup_id, references(:cleanups, on_delete: :nothing)

      timestamps()
    end

    create index(:events, [:cleanup_id])
  end
end
