defmodule TrashyWeb.CertificateLive do
  use TrashyWeb, :live_view
  import Ecto.DateTime
  import Timex.Format.DateTime

  def render(assigns) do
    ~H"""
      <.header class="text-center">
      Thanks, <%= @participant.name %>!
      <:subtitle>
      <p><%= @participant.name %> <%= @participant.last_name %></p>
      <p>Valid <%= @formatted_date %></p>
      </:subtitle>
      </.header>
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
        event = Trashy.Events.get_event!(participant.event_id)

        formatted_date = event.time
        |> Ecto.DateTime.from_naive_utc()
        |> Timex.Format.DateTime.format("{DYYYY}-{0M}-{0D}")
        # formatted_date = Timex.parse!(event.time, "{YYYY}-{0M}-{0D}")
        # naive_datetime = NaiveDateTime.from_iso8601(event.time)
        # formatted_date = NaiveDateTime.truncate(naive_datetime, :day)

        promotions = Trashy.Promotions.list_event_participant_promotions(participant_id)
        {:ok, assign(socket, participant_id: participant_id, promotions: promotions, participant: participant, formatted_date: formatted_date, current_user: nil)}

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
