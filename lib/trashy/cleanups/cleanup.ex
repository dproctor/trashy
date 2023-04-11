defmodule Trashy.Cleanups.Cleanup do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cleanups" do
    field :location, :string

    timestamps()
  end

  @doc false
  def changeset(cleanup, attrs) do
    cleanup
    |> cast(attrs, [:location])
    |> validate_required([:location])
  end
end
