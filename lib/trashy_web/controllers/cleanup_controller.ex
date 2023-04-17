defmodule TrashyWeb.CleanupController do
  use TrashyWeb, :controller

  alias Trashy.Cleanups
  alias Trashy.Cleanups.Cleanup

  def index(conn, _params) do
    cleanups = Cleanups.list_cleanups_for_user(conn.assigns.current_user)
    render(conn, :index, cleanups: cleanups)
  end

  def new(conn, _params) do
    changeset = Cleanups.change_cleanup(%Cleanup{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"cleanup" => cleanup_params}) do
    case Cleanups.create_cleanup(cleanup_params) do
      {:ok, cleanup} ->
        conn
        |> put_flash(:info, "Cleanup created successfully.")
        |> redirect(to: ~p"/organizer/cleanups/#{cleanup}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    cleanup = Cleanups.get_cleanup!(id)
    events = Trashy.Events.list_events_for_cleanup(cleanup)
    promotions = Trashy.Promotions.list_promotions_for_cleanup(cleanup)

    render(conn, :show,
      cleanup: cleanup,
      events: events,
      promotions: promotions
      # event_participants: participants
    )
  end

  def edit(conn, %{"id" => id}) do
    cleanup = Cleanups.get_cleanup!(id)
    changeset = Cleanups.change_cleanup(cleanup)
    render(conn, :edit, cleanup: cleanup, changeset: changeset)
  end

  def update(conn, %{"id" => id, "cleanup" => cleanup_params}) do
    cleanup = Cleanups.get_cleanup!(id)

    case Cleanups.update_cleanup(cleanup, cleanup_params) do
      {:ok, cleanup} ->
        conn
        |> put_flash(:info, "Cleanup updated successfully.")
        |> redirect(to: ~p"/organizer/cleanups/#{cleanup}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, cleanup: cleanup, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    cleanup = Cleanups.get_cleanup!(id)
    {:ok, _cleanup} = Cleanups.delete_cleanup(cleanup)

    conn
    |> put_flash(:info, "Cleanup deleted successfully.")
    |> redirect(to: ~p"/organizer/cleanups")
  end

  def events(conn, %{"cleanup_id" => cleanup_id}) do
    cleanup = Cleanups.get_cleanup!(cleanup_id)
    events = Trashy.Events.list_events_for_cleanup(cleanup)
    render(conn, :events, cleanup: cleanup, events: events)
  end
end
