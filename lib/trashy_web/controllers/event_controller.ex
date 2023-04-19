defmodule TrashyWeb.EventController do
  use TrashyWeb, :controller

  alias Trashy.Events
  alias Trashy.Events.Event

  def index(conn, _params) do
    events = Events.list_events()
    render(conn, :index, events: events)
  end

  def new(conn, _params) do
    changeset = Events.change_event(%Event{})
    cleanups = Trashy.Cleanups.list_cleanups_for_user(conn.assigns.current_user)
    render(conn, :new, changeset: changeset, cleanups: cleanups)
  end

  def create(conn, %{"event" => event_params}) do
    case Events.create_event(event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event created successfully.")
        |> redirect(to: ~p"/organizer/events/#{event}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    cleanup = Trashy.Cleanups.get_cleanup_with_preloads(event.cleanup_id)
    participants = Trashy.Events.list_event_participants_for_event(event)
    render(conn, :show, event: event, cleanup: cleanup, event_participants: participants)
  end

  def edit(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    changeset = Events.change_event(event)
    cleanups = Trashy.Cleanups.list_cleanups_for_user(conn.assigns.current_user)
    render(conn, :edit, event: event, changeset: changeset, cleanups: cleanups)
  end

  def update(conn, %{"id" => id, "event" => event_params}) do
    event = Events.get_event!(id)

    case Events.update_event(event, event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event updated successfully.")
        |> redirect(to: ~p"/organizer/events/#{event}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, event: event, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    {:ok, _event} = Events.delete_event(event)

    conn
    |> put_flash(:info, "Event deleted successfully.")
    |> redirect(to: ~p"/organizer/events")
  end

  @doc """
  Generates a QR code that links to the event.
  """
  def qr_code(conn, %{"url" => url}) do
    {:ok, decoded} = Base.decode64(url)

    {:ok, qr} =
      QRCode.create(decoded, :high)
      |> QRCode.render()

    conn
    |> put_resp_content_type("image/svg+xml")
    |> send_resp(200, qr)
  end

  @doc """
  A poster sutiable for printing for managing an event.
  """
  def poster(conn, %{"event_id" => id}) do
    event = Events.get_event!(id)

    event_checkin_url =
      Base.encode64(url(conn, ~p"/event_participants/checkin/#{id}/#{event.code}"))

    render(conn, :poster, event: event, event_checkin_url: event_checkin_url)
  end

  @doc """
  A certificate sutiable for printing for distributing at an event.
  """
  def certificate(conn, %{"event_id" => id}) do
    event = Events.get_event!(id)
    cleanup = Trashy.Cleanups.get_cleanup_with_preloads(event.cleanup_id)

    html =
      Phoenix.Template.render_to_string(TrashyWeb.EventHTML, "certificate", "html",
        event: event,
        cleanup: cleanup
      )

    {:ok, filename} = PdfGenerator.generate(html, page_size: "A5")
    {:ok, pdf_content} = File.read(filename)

    conn
    |> put_resp_content_type("application/pdf")
    |> send_resp(200, pdf_content)
  end
end
