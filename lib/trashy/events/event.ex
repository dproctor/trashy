defmodule Trashy.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :time, :utc_datetime
    belongs_to :cleanup, Trashy.Cleanups.Cleanup

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:time, :cleanup_id])
    |> validate_required([:time, :cleanup_id])
  end
end
