defmodule TrashyWeb.EventParticipantController do
  use TrashyWeb, :controller

  alias Trashy.Repo
  import Ecto.Query, warn: false
  alias TrashyWeb.CertificateLive
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
      {:ok, event_participant} ->
        send_confirmation_email(conn, event_participant)

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

  def get_event_participant(event_id, user) do
    query = from ep in EventParticipant,
              where: ep.event_id == ^event_id and ep.email == ^user["email"] and ep.first_name == ^user["first_name"]
    Repo.one(query)
  end

  def record_attendance(conn, %{"event_id" => event_id, "user" => user}) do
    # Check if event participant already exists
    participant = case get_event_participant(event_id, user) do
      nil ->
        {:ok, participant} = Events.create_event_participant(user)
        send_confirmation_email(conn, participant)
        participant
      participant ->
        participant
    end

    # Once the participant is known to exist, redirect
    redirect(conn, to: ~p"/event_participants/certificate/#{participant.id}/#{participant.code}")

  end

  defp send_confirmation_email(conn, participant) do
    html_body = """
    Thanks for helping clean up SF! You can access your rewards at #{TrashyWeb.Router.Helpers.live_url(conn, CertificateLive, participant.id, participant.code)}
    <br><br>
    Help us inspire more people to get involved and make the city a better place:  Please tag us in all all your amazing pictures and videos on our social media handles below:
    <br>Instagram: <a href="https://www.instagram.com/clean_up_the_city_sf/">@Clean_up_the_City_sf</a>
    <br>Twitter <a href="https://twitter.com/CivicJoyFund">@Civic_joy_fund</a>
    <br>Facebook: <a href="https://www.facebook.com/CleanUpTheCitySF">@CleanUpTheCitySF</a>
    <br><br>
    #CivicJoy #CivicJoyFund #SanFranciscoComeback #revitalizeSanFrancisco
    <br><br>
    Check out more ways to get involved at CivicJoyFund.org, and thanks for being part of San Francisco's inspiring comeback story!
    <br><br>
    Til next time,
    <br><br>
    - Your trashy Clean Up crew
    """

    Swoosh.Email.new()
    |> Swoosh.Email.to({participant.first_name, participant.email})
    |> Swoosh.Email.from({"Clean Up The City", "cutc-info@cleanupthecity.org"})
    |> Swoosh.Email.subject("Your trashy certificate")
    |> Swoosh.Email.html_body(html_body)
    |> Trashy.Mailer.deliver()
  end
end
