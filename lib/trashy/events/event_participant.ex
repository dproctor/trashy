defmodule Trashy.Events.EventParticipant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "event_participants" do
    field(:email, :string)
    field(:name, :string)
    field(:last_name, :string)
    field(:instagram, :string)
    field(:user_id, :id)
    field(:event_id, :id)
    field(:code, :string)

    timestamps()
  end

  @doc false
  def changeset(event_participant, attrs) do
    event_participant
    |> cast(attrs, [:name, :last_name, :instagram, :email, :event_id])
    |> validate_required([:name, :email, :event_id])
    |> put_change(:code, Ecto.UUID.generate())
    |> unique_constraint(:name_email_event_id, name: :event_participants_name_email_event_id_index, message: "Expecting a unique name/email/event_id combination")
  end
end
