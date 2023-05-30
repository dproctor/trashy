defmodule Trashy.Repo.Migrations.CreateInstagramField do
  use Ecto.Migration

  def change do
    alter table(:event_participants) do
      add :instagram, :string
    end
  end
end
