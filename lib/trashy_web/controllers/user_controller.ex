defmodule TrashyWeb.UserController do
  use TrashyWeb, :controller

  alias Trashy.Accounts

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, :index, users: users)
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, :show, user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)

    render(conn, :edit,
      user: user,
      changeset: changeset,
      cleanups: Trashy.Cleanups.list_cleanups()
    )
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    IO.inspect("DEVON")
    user = Accounts.get_user!(id)

    user_params =
      if Map.has_key?(user_params, "cleanups") do
        user_params =
          Map.update!(user_params, "cleanups", fn ids ->
            ids |> Enum.map(fn id -> %{"id" => id} end)
          end)
      else
        user_params
      end

    IO.inspect(user_params)

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
