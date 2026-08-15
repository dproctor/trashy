defmodule Trashy.Repo.Migrations.AddCompletionToEventParticipantPromotion do
  use Ecto.Migration

  def up do
    alter table(:event_participant_promotions) do
      add :claimed_at, :utc_datetime
      add :completed, :boolean, default: false, null: false
      add :completed_at, :utc_datetime
    end

    execute """
    UPDATE event_participant_promotions
    SET claimed_at = updated_at
    WHERE is_claimed = true AND claimed_at IS NULL
    """
  end

  def down do
    alter table(:event_participant_promotions) do
      remove :claimed_at
      remove :completed
      remove :completed_at
    end
  end
end
