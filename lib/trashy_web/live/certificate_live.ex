defmodule TrashyWeb.CertificateLive do
  use TrashyWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="hero min-h-screen bg-base-200">
      <div class="hero-content flex-col lg:flex-row-reverse">
        <div class="text-center lg:text-left">
          <h1 class="text-3xl font-bold">🌁 Thanks, <%= @participant.first_name %>! 🌇</h1>
          <p><%= @participant.first_name %> <%= @participant.last_name %></p>
          <p>Valid <%= @formatted_date %></p>
          <p>All-time cleanups: <%= @total_cleanup_count %></p>
          <p>Cleanups at this site: <%= @local_cleanup_count %></p>
        </div>
        <div class="card flex-shrink-0 w-full max-w-sm shadow-2xl bg-base-100">
          <div class="card-body">
            <div class="text-center lg:text-left">
              <h2 class="text-xl font-bold">Trash Pickup Certificate</h2>
              <h3 class="text-md">
                Here are the gift certificates for the weekly trash pick up. Please show this screen to the business owner and check off your one time use certificate in the app at the location.
              </h3>
            </div>
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
                    <td class="px-1 border"><%= promotion.promotion.merchant %></td>
                    <td class="px-1 border"><%= promotion.promotion.details %></td>
                    <td class="px-1 border">
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
          </div>
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
           formatted_date: Calendar.strftime(event.time, "%m/%d/%Y"),
           current_user: nil
         ), layout: false}

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
