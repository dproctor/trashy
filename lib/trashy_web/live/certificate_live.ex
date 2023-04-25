defmodule TrashyWeb.CertificateLive do
  use TrashyWeb, :live_view

  def render(assigns) do
    ~H"""
    <.header class="text-center">
      Certificate
      <:subtitle>Claim your rewards</:subtitle>
    </.header>
    <table class="table-fixed">
      <thead>
        <tr>
          <th>Merchant</th>
          <th>Details</th>
          <th>Claimed</th>
        </tr>
      </thead>
      <tbody>
        <%= for promotion <- @promotions do %>
          <tr>
            <td class="px-1"><%= promotion.promotion.merchant %></td>
            <td class="px-1"><%= promotion.promotion.details %></td>
            <td class="px-1">
              <.input
                field={promotion.is_claimed}
                value={promotion.is_claimed}
                name="promotion"
                type="checkbox"
                phx-click="claim_reward"
                phx-value-promotion_id={promotion.id}
                disabled={promotion.is_claimed}
                phx-disconnected={JS.set_attribute({"readonly", true})}
                phx-connected={JS.remove_attribute("readonly")}
              />
            </td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  def mount(%{"participant_id" => participant_id, "code" => code}, _session, socket) do
    participant = Trashy.Events.get_event_participant!(participant_id)

    case code == participant.code do
      true ->
        promotions = Trashy.Promotions.list_event_participant_promotions(participant_id)
        {:ok, assign(socket, participant_id: participant_id, promotions: promotions)}

      false ->
        raise TrashyWeb.CertificateLive.InvalidCodeError
    end
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

defmodule TrashyWeb.CertificateLive.InvalidCodeError do
  defexception message: "invalid code", plug_status: 404
end
