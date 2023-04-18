defmodule Trashy.Repo.Migrations.CreateEventParticipantPromotions do
  use Ecto.Migration

  def change do
    create table(:event_participant_promotions) do
      add(:is_claimed, :boolean, default: false, null: false)
      add(:promotion_id, references(:promotions, on_delete: :nothing))
      add(:event_participant_id, references(:event_participants, on_delete: :nothing))

      timestamps()
    end

    create(index(:event_participant_promotions, [:promotion_id]))
    create(index(:event_participant_promotions, [:event_participant_id]))
  end
end
