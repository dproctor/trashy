defmodule Trashy.Repo.Migrations.AddEventParticipantFields do
  use Ecto.Migration

  def change do
    alter table(:event_participants) do
      add :num_bags_collected, :integer
      add :phone_number, :string
    end
  end
end
