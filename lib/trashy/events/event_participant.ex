defmodule Trashy.Events.EventParticipant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "event_participants" do
    field(:email, :string)
    field(:first_name, :string)
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
    |> cast(attrs, [:first_name, :last_name, :instagram, :email, :event_id])
    |> validate_required([:first_name, :email, :event_id])
    |> put_change(:code, Ecto.UUID.generate())
    |> unique_constraint(:name_email_event_id, first_name: :event_participants_name_email_event_id_index, message: "Expecting a unique firstname/email/event_id combination")
  end
end
