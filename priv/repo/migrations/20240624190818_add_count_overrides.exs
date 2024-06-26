defmodule Trashy.Repo.Migrations.AddCountOverrides do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :override_participant_count, :integer
      add :override_bag_count, :integer
    end
  end
end
