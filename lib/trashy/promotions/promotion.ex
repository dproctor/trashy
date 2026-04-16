defmodule Trashy.Promotions.Promotion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "promotions" do
    field(:details, :string)
    field(:merchant, :string)
    belongs_to(:cleanup, Trashy.Cleanups.Cleanup)
    field(:is_disabled, :boolean)
    field(:icon, :string)
    field(:choices, {:array, :string}, default: [])

    timestamps()
  end

  @doc false
  def changeset(promotion, attrs) do
    attrs =
      case Map.fetch(attrs, "choices") do
        {:ok, val} ->
          Map.put(
            attrs,
            "choices",
            val
            |> String.split("\n", trim: true)
            |> Enum.map(&String.trim/1)
          )

        :error ->
          attrs
      end

    promotion
    |> cast(attrs, [
      :merchant,
      :details,
      :cleanup_id,
      :is_disabled,
      :icon,
      :choices
    ])
    |> validate_required([:merchant, :details, :cleanup_id])
  end
end
