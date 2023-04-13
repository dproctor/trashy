defmodule Trashy.Repo.Migrations.CreateCleanups do
  use Ecto.Migration

  def change do
    create table(:cleanups) do
      add :location, :string
      add :neighborhood, :string

      timestamps()
    end
  end
end
