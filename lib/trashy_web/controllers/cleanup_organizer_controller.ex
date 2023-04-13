defmodule TrashyWeb.CleanupOrganizerController do
  use TrashyWeb, :controller

  alias Trashy.Cleanups
  alias Trashy.Cleanups.CleanupOrganizer

  def index(conn, _params) do
    cleanup_organizers = Cleanups.list_cleanup_organizers()
    render(conn, :index, cleanup_organizers: cleanup_organizers)
  end

  def new(conn, _params) do
    changeset = Cleanups.change_cleanup_organizer(%CleanupOrganizer{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"cleanup_organizer" => cleanup_organizer_params}) do
    case Cleanups.create_cleanup_organizer(cleanup_organizer_params) do
      {:ok, cleanup_organizer} ->
        conn
        |> put_flash(:info, "Cleanup organizer created successfully.")
        |> redirect(to: ~p"/cleanup_organizers/#{cleanup_organizer}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    cleanup_organizer = Cleanups.get_cleanup_organizer!(id)
    render(conn, :show, cleanup_organizer: cleanup_organizer)
  end

  def edit(conn, %{"id" => id}) do
    cleanup_organizer = Cleanups.get_cleanup_organizer!(id)
    changeset = Cleanups.change_cleanup_organizer(cleanup_organizer)
    render(conn, :edit, cleanup_organizer: cleanup_organizer, changeset: changeset)
  end

  def update(conn, %{"id" => id, "cleanup_organizer" => cleanup_organizer_params}) do
    cleanup_organizer = Cleanups.get_cleanup_organizer!(id)

    case Cleanups.update_cleanup_organizer(cleanup_organizer, cleanup_organizer_params) do
      {:ok, cleanup_organizer} ->
        conn
        |> put_flash(:info, "Cleanup organizer updated successfully.")
        |> redirect(to: ~p"/cleanup_organizers/#{cleanup_organizer}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, cleanup_organizer: cleanup_organizer, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    cleanup_organizer = Cleanups.get_cleanup_organizer!(id)
    {:ok, _cleanup_organizer} = Cleanups.delete_cleanup_organizer(cleanup_organizer)

    conn
    |> put_flash(:info, "Cleanup organizer deleted successfully.")
    |> redirect(to: ~p"/cleanup_organizers")
  end
end
