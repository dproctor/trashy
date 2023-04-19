defmodule Trashy.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add(:time, :utc_datetime)
      add(:cleanup_id, references(:cleanups, on_delete: :nothing))
      add(:code, :string, default: fragment("gen_random_uuid()::text"))

      timestamps()
    end

    create(index(:events, [:cleanup_id]))
  end
end
