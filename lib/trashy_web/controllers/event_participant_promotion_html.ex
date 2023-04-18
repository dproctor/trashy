defmodule TrashyWeb.EventParticipantPromotionHTML do
  use TrashyWeb, :html

  embed_templates "event_participant_promotion_html/*"

  @doc """
  Renders a event_participant_promotion form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def event_participant_promotion_form(assigns)
end
