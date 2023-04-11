defmodule Trashy.Repo.Migrations.CreatePromotions do
  use Ecto.Migration

  def change do
    create table(:promotions) do
      add :merchant, :string
      add :details, :string
      add :cleanup_id, references(:cleanups, on_delete: :nothing)

      timestamps()
    end

    create index(:promotions, [:cleanup_id])
  end
end
