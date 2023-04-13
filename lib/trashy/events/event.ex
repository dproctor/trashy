defmodule Trashy.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :time, :utc_datetime
    field :cleanup_id, :id

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:time, :cleanup_id])
    |> validate_required([:time, :cleanup_id])
  end
end
