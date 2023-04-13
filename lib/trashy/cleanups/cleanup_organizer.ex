defmodule Trashy.Cleanups.CleanupOrganizer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cleanup_organizers" do
    field :cleanup_id, :id
    field :organizer_id, :id

    timestamps()
  end

  @doc false
  def changeset(cleanup_organizer, attrs) do
    cleanup_organizer
    |> cast(attrs, [])
    |> validate_required([])
  end
end
