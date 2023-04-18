defmodule TrashyWeb.CertificateLive do
  use TrashyWeb, :live_view

  def render(assigns) do
    ~H"""
    <.header class="text-center">
      Certificate
      <:subtitle>Claim your rewards</:subtitle>
    </.header>
    <.table id="promotions" rows={@promotions}>
      <:col :let={promotion} label="Merchant"><%= promotion.promotion.merchant %></:col>
      <:col :let={promotion} label="Details"><%= promotion.promotion.details %></:col>
      <:col :let={promotion} label="Claimed">
        <.input
          field={promotion.is_claimed}
          name="devon"
          value={promotion.is_claimed}
          type="checkbox"
          phx-click="claim_reward"
          phx-value-promotion_id={promotion.id}
          disabled={promotion.is_claimed}
          phx-disconnected={JS.set_attribute({"readonly", true})}
          phx-connected={JS.remove_attribute("readonly")}
        />
      </:col>
    </.table>
    """
  end

  def mount(%{"participant_id" => participant_id}, _session, socket) do
    promotions = Trashy.Promotions.list_event_participant_promotions(participant_id)

    {:ok, assign(socket, participant_id: participant_id, promotions: promotions)}
  end

  def handle_event(
        "claim_reward",
        %{"promotion-id" => promotion_id},
        %{assigns: %{participant_id: participant_id}} = socket
      ) do
    promotion = Trashy.Promotions.get_event_participant_promotion!(promotion_id)

    case promotion.is_claimed do
      true ->
        {:noreply, assign(socket, success: false)}

      false ->
        Trashy.Promotions.update_event_participant_promotion(promotion, %{is_claimed: true})
        promotions = Trashy.Promotions.list_event_participant_promotions(participant_id)
        {:noreply, assign(socket, success: true, promotions: promotions)}
    end
  end
end
