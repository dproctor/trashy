defmodule Trashy.Events.EventParticipant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "event_participants" do
    field(:email, :string)
    field(:name, :string)
    field(:user_id, :id)
    field(:event_id, :id)
    field(:code, :string, autogenerate: Ecto.UUID.generate())

    timestamps()
  end

  @doc false
  def changeset(event_participant, attrs) do
    event_participant
    |> cast(attrs, [:name, :email, :event_id])
    |> validate_required([:name, :email, :event_id])
  end
end