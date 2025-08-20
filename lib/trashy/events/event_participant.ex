defmodule Trashy.Events.EventParticipant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "event_participants" do
    field(:email, :string)
    field(:first_name, :string)
    field(:last_name, :string)
    # deprecated, no longer populated.
    field(:instagram, :string)
    field(:user_id, :id)
    field(:event_id, :id)
    field(:code, :string)
    field(:num_bags_collected, :integer)
    field(:phone_number, :string)

    timestamps()
  end

  @doc false
  def changeset(event_participant, attrs) do
    event_participant
    |> cast(attrs, [
      :first_name,
      :last_name,
      :instagram,
      :email,
      :event_id,
      :num_bags_collected,
      :phone_number
    ])
    |> update_change(:first_name, &trim/1)
    |> update_change(:last_name, &trim/1)
    |> validate_required([:first_name, :email, :event_id])
    |> put_change(:code, Ecto.UUID.generate())
    |> unique_constraint(:name_email_event_id,
      first_name: :event_participants_name_email_event_id_index,
      message: "Expecting a unique firstname/email/event_id combination"
    )
  end

  defp trim(binary) when is_binary(binary), do: String.trim(binary)
  defp trim(nil), do: nil
end
