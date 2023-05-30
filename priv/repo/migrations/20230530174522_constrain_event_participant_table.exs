defmodule Trashy.Repo.Migrations.ConstrainEventParticipantTable do
  use Ecto.Migration

  def change do
    create unique_index(:event_participants, [:name, :email, :event_id], name: :event_participants_name_email_event_id_index)
  end
end
