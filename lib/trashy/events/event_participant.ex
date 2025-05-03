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
    |> trim_whitespace([
      :first_name,
      :last_name,
      :instagram,
      :email,
      :phone_number
    ])
    |> validate_required([:first_name, :email, :event_id])
    |> put_change(:code, Ecto.UUID.generate())
    |> unique_constraint(:name_email_event_id,
      name: :event_participants_name_email_event_id_index,
      message: "Expecting a unique firstname/email/event_id combination"
    )
  end

  defp trim_whitespace(changeset, fields) do
    Enum.reduce(fields, changeset, fn field, acc ->
      case get_change(acc, field) do
        nil -> acc
        value when is_binary(value) -> put_change(acc, field, String.trim(value))
        _ -> acc
      end
    end)
  end
end
