defmodule Trashy.Repo.Migrations.AddEventParticipantLastName do
  use Ecto.Migration

  def change do
    alter table(:event_participants) do
      add :last_name, :string
    end
  end
end
