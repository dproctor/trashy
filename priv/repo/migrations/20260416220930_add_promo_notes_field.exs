defmodule Trashy.Repo.Migrations.AddPromoNotesField do
  use Ecto.Migration

  def change do
    alter table(:promotions) do
      add(:show_notes_field, :boolean, default: false, null: false)
    end

    alter table(:event_participant_promotions) do
      add(:notes, :string, default: "", null: "")
    end
  end
end
