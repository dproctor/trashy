defmodule TrashyWeb.CleanupHTML do
  use TrashyWeb, :html

  embed_templates "cleanup_html/*"

  @doc """
  Renders a cleanup form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def cleanup_form(assigns)
end
