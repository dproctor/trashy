defmodule TrashyWeb.EventParticipantPromotionController do
  use TrashyWeb, :controller

  alias Trashy.Promotions
  alias Trashy.Promotions.EventParticipantPromotion

  def index(conn, _params) do
    event_participant_promotions = Promotions.list_event_participant_promotions()
    render(conn, :index, event_participant_promotions: event_participant_promotions)
  end

  def new(conn, _params) do
    changeset = Promotions.change_event_participant_promotion(%EventParticipantPromotion{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"event_participant_promotion" => event_participant_promotion_params}) do
    case Promotions.create_event_participant_promotion(event_participant_promotion_params) do
      {:ok, event_participant_promotion} ->
        conn
        |> put_flash(:info, "Event participant promotion created successfully.")
        |> redirect(to: ~p"/event_participant_promotions/#{event_participant_promotion}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    event_participant_promotion = Promotions.get_event_participant_promotion!(id)
    render(conn, :show, event_participant_promotion: event_participant_promotion)
  end

  def edit(conn, %{"id" => id}) do
    event_participant_promotion = Promotions.get_event_participant_promotion!(id)
    changeset = Promotions.change_event_participant_promotion(event_participant_promotion)
    render(conn, :edit, event_participant_promotion: event_participant_promotion, changeset: changeset)
  end

  def update(conn, %{"id" => id, "event_participant_promotion" => event_participant_promotion_params}) do
    event_participant_promotion = Promotions.get_event_participant_promotion!(id)

    case Promotions.update_event_participant_promotion(event_participant_promotion, event_participant_promotion_params) do
      {:ok, event_participant_promotion} ->
        conn
        |> put_flash(:info, "Event participant promotion updated successfully.")
        |> redirect(to: ~p"/event_participant_promotions/#{event_participant_promotion}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, event_participant_promotion: event_participant_promotion, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    event_participant_promotion = Promotions.get_event_participant_promotion!(id)
    {:ok, _event_participant_promotion} = Promotions.delete_event_participant_promotion(event_participant_promotion)

    conn
    |> put_flash(:info, "Event participant promotion deleted successfully.")
    |> redirect(to: ~p"/event_participant_promotions")
  end
end
