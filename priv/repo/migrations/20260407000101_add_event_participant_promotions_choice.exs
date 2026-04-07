defmodule Trashy.Repo.Migrations.AddEventParticipantPromotionsChoice do
  use Ecto.Migration

  def change do
    alter table(:event_participant_promotions) do
      add(:choice, :string, default: "", null: "")
    end
  end
end
