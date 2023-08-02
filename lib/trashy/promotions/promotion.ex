defmodule Trashy.Promotions.Promotion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "promotions" do
    field(:details, :string)
    field(:merchant, :string)
    belongs_to(:cleanup, Trashy.Cleanups.Cleanup)
    field(:is_disabled, :boolean)
    field(:icon, :string)

    timestamps()
  end

  @doc false
  def changeset(promotion, attrs) do
    promotion
    |> cast(attrs, [:merchant, :details, :cleanup_id, :is_disabled, :icon])
    |> validate_required([:merchant, :details, :cleanup_id])
  end
end
