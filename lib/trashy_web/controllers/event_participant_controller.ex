defmodule TrashyWeb.EventParticipantController do
  use TrashyWeb, :controller

  alias Trashy.Events
  alias Trashy.Events.EventParticipant

  def index(conn, _params) do
    event_participants = Events.list_event_participants()
    render(conn, :index, event_participants: event_participants)
  end

  def new(conn, %{"event_id" => event_id}) do
    changeset = Events.change_event_participant(%EventParticipant{event_id: event_id})
    render(conn, :new, changeset: changeset, event_id: event_id)
  end

  def create(conn, %{"event_participant" => event_participant_params, "event_id" => event_id}) do
    case Events.create_event_participant(event_participant_params) do
      {:ok, _event_participant} ->
        conn
        |> put_flash(:info, "Event participant created successfully.")
        |> redirect(to: ~p"/organizer/events/#{event_id}")

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

  def update(conn, %{
        "id" => id,
        "event_participant" => event_participant_params,
        "event_id" => event_id
      }) do
    event_participant = Events.get_event_participant!(id)

    case Events.update_event_participant(event_participant, event_participant_params) do
      {:ok, _event_participant} ->
        conn
        |> put_flash(:info, "Event participant updated successfully.")
        |> redirect(to: ~p"/organizer/events/#{event_id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, event_participant: event_participant, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id, "event_id" => event_id}) do
    event_participant = Events.get_event_participant!(id)
    {:ok, _event_participant} = Events.delete_event_participant(event_participant)

    conn
    |> put_flash(:info, "Event participant deleted successfully.")
    |> redirect(to: ~p"/organizer/events/#{event_id}")
  end

  def checkin(conn, %{"event_id" => event_id, "code" => code}) do
    event = Events.get_event!(event_id)

    case code == event.code do
      true ->
        render(conn, :checkin, event: event, form: Phoenix.HTML.FormData.to_form(%{}, as: "user"))

      false ->
        conn
        |> put_status(:not_found)
        |> Phoenix.Controller.put_view(TrashyWeb.ErrorHTML)
        |> Phoenix.Controller.render(:"404")
        |> halt()
    end
  end

  def record_attendance(conn, %{"event_id" => event_id, "user" => user}) do
    event = Events.get_event!(event_id)
    {:ok, participant} = Events.create_event_participant(user)

    %{"name" => name, "email" => email} = user

    Swoosh.Email.new()
    |> Swoosh.Email.to({name, email})
    |> Swoosh.Email.from({"TrashySF", "devon.proctor@gmail.com"})
    |> Swoosh.Email.subject("Your trashy certificate")
    |> Swoosh.Email.text_body(
      "Thanks for helping to clean up SF! You can access your rewards at #{~p"/event_participants/certificate/1"}"
    )
    |> Trashy.Mailer.deliver()

    redirect(conn, to: ~p"/event_participants/certificate/#{participant.id}/#{participant.code}")
  end
end
