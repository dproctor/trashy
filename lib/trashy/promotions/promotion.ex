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
    |> cast(attrs, [:merchant, :details])
    |> validate_required([:merchant, :details])
  end
end
