defmodule Trashy.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field(:time, :utc_datetime)
    belongs_to(:cleanup, Trashy.Cleanups.Cleanup)
    field(:code, :string)
    field(:override_participant_count, :integer)
    field(:override_bag_count, :integer)

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:time, :cleanup_id, :override_participant_count, :override_bag_count])
    |> validate_required([:time, :cleanup_id])
    |> put_change(:code, Ecto.UUID.generate())
  end
end
