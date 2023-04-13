defmodule Trashy.Cleanups.Cleanup do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cleanups" do
    field :location, :string
    field :neighborhood, :string
    many_to_many :organizers, Trashy.Accounts.User, join_through: Trashy.Cleanups.CleanupOrganizer
    has_many :promotions, Trashy.Promotions.Promotion

    timestamps()
  end

  @doc false
  def changeset(cleanup, attrs) do
    cleanup
    |> cast(attrs, [:neighborhood, :location])
    |> validate_required([:neighborhood, :location])
  end
end
