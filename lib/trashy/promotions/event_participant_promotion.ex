defmodule Trashy.Promotions.EventParticipantPromotion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "event_participant_promotions" do
    field(:is_claimed, :boolean, default: false)
    # field :promotion_id, :id
    belongs_to(:promotion, Trashy.Promotions.Promotion)
    belongs_to(:event_participant, Trashy.Events.EventParticipant)
    field(:choice, :string, default: "")
    field(:notes, :string, default: "")

    field :claimed_at, :utc_datetime
    field :completed, :boolean, default: false
    field :completed_at, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(event_participant_promotion, attrs) do
    event_participant_promotion
    |> cast(attrs, [
      :is_claimed,
      :promotion_id,
      :event_participant_id,
      :choice,
      :notes,
      :claimed_at,
      :completed,
      :completed_at
    ])
    |> validate_required([:is_claimed, :promotion_id, :event_participant_id])
  end

  def completion_changeset(epp, true) do
    change(epp,
      completed: true,
      completed_at: DateTime.utc_now() |> DateTime.truncate(:second)
    )
  end

  def completion_changeset(epp, false) do
    change(epp, completed: false, completed_at: nil)
  end
end
