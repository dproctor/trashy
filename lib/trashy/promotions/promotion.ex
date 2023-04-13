defmodule Trashy.Promotions.Promotion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "promotions" do
    field :details, :string
    field :merchant, :string
    field :cleanup_id, :id

    timestamps()
  end

  @doc false
  def changeset(promotion, attrs) do
    promotion
    |> cast(attrs, [:merchant, :details, :cleanup_id])
    |> validate_required([:merchant, :details, :cleanup_id])
  end
end
