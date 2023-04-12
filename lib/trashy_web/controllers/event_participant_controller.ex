defmodule TrashyWeb.EventParticipantController do
  use TrashyWeb, :controller

  alias Trashy.Events
  alias Trashy.Events.EventParticipant

  def index(conn, _params) do
    event_participants = Events.list_event_participants()
    render(conn, :index, event_participants: event_participants)
  end

  def new(conn, _params) do
    changeset = Events.change_event_participant(%EventParticipant{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"event_participant" => event_participant_params}) do
    case Events.create_event_participant(event_participant_params) do
      {:ok, event_participant} ->
        conn
        |> put_flash(:info, "Event participant created successfully.")
        |> redirect(to: ~p"/organizer/event_participants/#{event_participant}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    event_participant = Events.get_event_participant!(id)
    render(conn, :show, event_participant: event_participant)
  end

  def edit(conn, %{"id" => id}) do
    event_participant = Events.get_event_participant!(id)
    changeset = Events.change_event_participant(event_participant)
    render(conn, :edit, event_participant: event_participant, changeset: changeset)
  end

  def update(conn, %{"id" => id, "event_participant" => event_participant_params}) do
    event_participant = Events.get_event_participant!(id)

    case Events.update_event_participant(event_participant, event_participant_params) do
      {:ok, event_participant} ->
        conn
        |> put_flash(:info, "Event participant updated successfully.")
        |> redirect(to: ~p"/organizer/event_participants/#{event_participant}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, event_participant: event_participant, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    event_participant = Events.get_event_participant!(id)
    {:ok, _event_participant} = Events.delete_event_participant(event_participant)

    conn
    |> put_flash(:info, "Event participant deleted successfully.")
    |> redirect(to: ~p"/organizer/event_participants")
  end

  def checkin(conn, %{"event_id" => event_id}) do
    event = Events.get_event!(event_id)
    render(conn, :checkin, event: event, form: Phoenix.HTML.FormData.to_form(%{}, as: "user"))
  end

  def record_attendance(conn, %{"event_id" => event_id, "user" => user}) do
    event = Events.get_event!(event_id)
    Events.create_event_participant(user)
    render(conn, :post_record_attendance, event: event)
  end
end
