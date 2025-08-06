defmodule TrashyWeb.UserController do
  use TrashyWeb, :controller

  alias Trashy.Accounts
  alias Trashy.Cleanups

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, :index, users: users)
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, :show, user: user)
  end

  def edit(conn, %{"id" => id}) do
    user =
      Accounts.get_user!(id)
      |> Map.update(:cleanups, [], fn cleanups ->
        Enum.map(cleanups, fn cleanup -> cleanup.id end)
      end)

    changeset = Accounts.change_user(user)

    all_cleanups = Trashy.Cleanups.list_cleanups() |> Enum.map(fn c -> {"#{c.neighborhood} (#{c.location})", c.id} end)

    render(conn, :edit,
      user: user,
      changeset: changeset,
      all_cleanups: all_cleanups
    )
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    cleanup_organizers =
      Cleanups.list_cleanup_organizers_for_user(id)
      |> Enum.map(fn co -> {co.cleanup_id, co} end)
      |> Map.new()

    old_cleanups =
      cleanup_organizers |> Enum.map(fn {cleanup_id, _co} -> cleanup_id end) |> MapSet.new()

    new_cleanups =
      user_params
      |> Map.get("cleanups", [])
      |> Enum.map(fn id -> id |> Integer.parse() |> elem(0) end)
      |> MapSet.new()

    user_params = Map.delete(user_params, "cleanups")

    MapSet.difference(new_cleanups, old_cleanups)
    |> Enum.map(fn cleanup_id ->
      Cleanups.create_cleanup_organizer(%{cleanup_id: cleanup_id, organizer_id: id})
    end)

    MapSet.difference(old_cleanups, new_cleanups)
    |> Enum.map(fn cleanup_id ->
      Map.get(cleanup_organizers, cleanup_id)
      |> Cleanups.delete_cleanup_organizer()
    end)

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: ~p"/admin/users/#{user}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit,
          user: user,
          changeset: changeset,
          cleanups: Trashy.Cleanups.list_cleanups()
        )
    end
  end
end
