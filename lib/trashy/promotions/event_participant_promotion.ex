defmodule Trashy.Promotions.EventParticipantPromotion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "event_participant_promotions" do
    field :is_claimed, :boolean, default: false
    # field :promotion_id, :id
    belongs_to :promotion, Trashy.Promotions.Promotion
    belongs_to :event_participant, Trashy.Events.EventParticipant

    timestamps()
  end

  @doc false
  def changeset(event_participant_promotion, attrs) do
    event_participant_promotion
    |> cast(attrs, [:is_claimed, :promotion_id, :event_participant_id])
    |> validate_required([:is_claimed, :promotion_id, :event_participant_id])
  end
end
