defmodule TrashyWeb.CleanupOrganizerHTML do
  use TrashyWeb, :html

  embed_templates "cleanup_organizer_html/*"

  @doc """
  Renders a cleanup_organizer form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def cleanup_organizer_form(assigns)
end
