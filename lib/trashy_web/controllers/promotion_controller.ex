defmodule TrashyWeb.PromotionController do
  use TrashyWeb, :controller

  alias Trashy.Promotions
  alias Trashy.Promotions.Promotion

  def index(conn, _params) do
    promotions = Promotions.list_promotions()
    render(conn, :index, promotions: promotions)
  end

  def new(conn, _params) do
    changeset = Promotions.change_promotion(%Promotion{})
    cleanups = Trashy.Cleanups.list_cleanups_for_user(conn.assigns.current_user)
    render(conn, :new, changeset: changeset, cleanups: cleanups)
  end

  def create(conn, %{"promotion" => promotion_params}) do
    case Promotions.create_promotion(promotion_params) do
      {:ok, promotion} ->
        conn
        |> put_flash(:info, "Promotion created successfully.")
        |> redirect(to: ~p"/organizer/promotions/#{promotion}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    promotion = Promotions.get_promotion!(id)
    render(conn, :show, promotion: promotion)
  end

  def edit(conn, %{"id" => id}) do
    promotion = Promotions.get_promotion!(id)
    changeset = Promotions.change_promotion(promotion)
    cleanups = Trashy.Cleanups.list_cleanups_for_user(conn.assigns.current_user)
    render(conn, :edit, promotion: promotion, changeset: changeset, cleanups: cleanups)
  end

  def update(conn, %{"id" => id, "promotion" => promotion_params}) do
    promotion = Promotions.get_promotion!(id)

    case Promotions.update_promotion(promotion, promotion_params) do
      {:ok, promotion} ->
        conn
        |> put_flash(:info, "Promotion updated successfully.")
        |> redirect(to: ~p"/organizer/promotions/#{promotion}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, promotion: promotion, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    promotion = Promotions.get_promotion!(id)
    {:ok, _promotion} = Promotions.delete_promotion(promotion)

    conn
    |> put_flash(:info, "Promotion deleted successfully.")
    |> redirect(to: ~p"/organizer/promotions")
  end
end
