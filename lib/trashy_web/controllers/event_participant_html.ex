defmodule TrashyWeb.EventParticipantHTML do
  use TrashyWeb, :html

  embed_templates "event_participant_html/*"
  import Phoenix.HTML.Form

  @doc """
  Renders a event_participant form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def event_participant_form(assigns)
end
