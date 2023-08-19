defmodule TrashyWeb.CertificateLive do
  use TrashyWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-bl from-[#3B2F64] to-[#2C293F]">
      <div class="flex-col lg:flex-row-reverse">
        <p class="p-4 text-white text-right">
          <%= @participant.first_name %> <%= @participant.last_name %>
        </p>
        <div class="text-center lg:text-left">
          <h1 class="text-5xl font-bold text-white mt-16 m-6">Today's Perks</h1>
          <h2 class="text-lg font-bold text-white m-6"><%= @formatted_date %></h2>
          <p class="text-md text-white m-6">
            Here’s what’s good in the neighborhood! Redeem each reward by showing this screen to our participating partners. Valid for today only.
          </p>
        </div>
        <div class="flex flex-col space-y-4 m-8">
          <%= for promotion <- @promotions do %>
            <div class={"flex flex-row items-center space-x-2 bg-[#56506F] p-4 rounded " <> if promotion.is_claimed do "opacity-25" else "" end}>
              <h1 class="basis-1/6 text-3xl">
                <%= promotion.promotion.icon %>
              </h1>
              <div class="basis-2/3">
                <h3 class="text-white">
                  <%= promotion.promotion.merchant %>
                </h3>
                <h4 class="text-xs text-white">
                  <%= promotion.promotion.details %>
                </h4>
              </div>
              <button
                class="btn basis-1/6 bg-white text-[#362D58] disabled:text-white rounded"
                disabled={promotion.is_claimed}
                phx-click="claim_reward"
                phx-value-promotion_id={promotion.id}
              >
                <%= if promotion.is_claimed do %>
                  Redeemed
                <% else %>
                  Redeem
                <% end %>
              </button>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def mount(%{"participant_id" => participant_id, "code" => code}, _session, socket) do
    participant = Trashy.Events.get_event_participant!(participant_id)

    case code == participant.code do
      true ->
        event = Trashy.Events.get_event!(participant.event_id)

        {:ok,
         assign(socket,
           participant_id: participant_id,
           promotions: Trashy.Promotions.list_event_participant_promotions(participant_id),
           participant: participant,
           total_cleanup_count: Trashy.Events.get_total_participant_cleanup_count(participant),
           local_cleanup_count:
             Trashy.Events.get_local_participant_cleanup_count(participant, event),
           formatted_date: Calendar.strftime(event.time, "%B %-d, %Y"),
           current_user: nil
         ), layout: false}

      false ->
        raise TrashyWeb.CertificateLive.InvalidCodeError
    end
  end

  def handle_event(
        "claim_reward",
        %{"promotion_id" => promotion_id},
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
