defmodule TrashyWeb.PromotionHTML do
  use TrashyWeb, :html

  embed_templates "promotion_html/*"

  @doc """
  Renders a promotion form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def promotion_form(assigns)
end
