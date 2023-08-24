defmodule Trashy.Repo.Migrations.ChangeOnDeleteBehavior do
  use Ecto.Migration

  def up do
    drop constraint(
           :event_participant_promotions,
           "event_participant_promotions_event_participant_id_fkey"
         )

    drop constraint(
           :event_participants,
           "event_participants_event_id_fkey"
         )

    alter table(:event_participant_promotions) do
      modify(:event_participant_id, references(:event_participants, on_delete: :delete_all))
    end

    alter table(:event_participants) do
      modify(:event_id, references(:events, on_delete: :delete_all))
    end
  end

  def down do
    drop constraint(
           :event_participant_promotions,
           "event_participant_promotions_event_participant_id_fkey"
         )

    drop constraint(
           :event_participants,
           "event_participants_event_id_fkey"
         )

    alter table(:event_participant_promotions) do
      modify(:event_participant_id, references(:event_participants, on_delete: :nothing))
    end

    alter table(:event_participants) do
      modify(:event_id, references(:events, on_delete: :nothing))
    end
  end
end
