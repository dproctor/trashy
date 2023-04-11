defmodule TrashyWeb.CleanupController do
  use TrashyWeb, :controller

  alias Trashy.Cleanups
  alias Trashy.Cleanups.Cleanup

  def index(conn, _params) do
    cleanups = Cleanups.list_cleanups()
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
        |> redirect(to: ~p"/cleanups/#{cleanup}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    cleanup = Cleanups.get_cleanup!(id)
    render(conn, :show, cleanup: cleanup)
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
        |> redirect(to: ~p"/cleanups/#{cleanup}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, cleanup: cleanup, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    cleanup = Cleanups.get_cleanup!(id)
    {:ok, _cleanup} = Cleanups.delete_cleanup(cleanup)

    conn
    |> put_flash(:info, "Cleanup deleted successfully.")
    |> redirect(to: ~p"/cleanups")
  end
end
