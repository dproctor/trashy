defmodule TrashyWeb.CertificateLive do
  use TrashyWeb, :live_view

  def render(assigns) do
    ~H"""
    <%= if Enum.member?([1, 5, 10, 25, 50, 100, 200, 300, 500, 1000], @total_cleanup_count) do %>
      <div id="page-load" phx-hook="DisplayConfetti"></div>
    <% end %>
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
          <%= for epp <- @epps do %>
            <% promotion = epp.promotion %>
            <div class={"flex flex-row items-center space-x-2 bg-[#56506F] p-4 rounded " <> if epp.is_claimed do "opacity-25" else "" end}>
              <h1 class="basis-1/6 text-3xl">
                <%= promotion.icon %>
              </h1>
              <div class="basis-2/3">
                <h3 class="text-white">
                  <%= promotion.merchant %>
                </h3>
                <h4 class="text-xs text-white">
                  <%= promotion.details %>
                </h4>
              </div>
              <%= if epp.is_claimed do %>
              <% else %>
                <label
                  class={"btn basis-1/6 bg-white text-[#362D58] rounded normal-case border-none " <> if epp.is_claimed do "text-white" else "" end}
                  for={"claim_reward_modal_#{epp.id}"}
                >
                  Redeem
                </label>
              <% end %>
            </div>
            <input type="checkbox" id={"claim_reward_modal_#{epp.id}"} class="modal-toggle" />
            <div class="modal">
              <div class="modal-box">
                <div class="flex flex-col space-y-4">
                  <p class="text-center text-[#362D58]">Show this to the merchant.</p>
                  <div class="flex flex-row items-center bg-[#362D58] space-x-2 p-4 rounded" }>
                    <h1 class="basis-1/6 text-3xl p-2 rounded">
                      <%= promotion.icon %>
                    </h1>
                    <div class="basis-2/3">
                      <h3 class="text-white">
                        <%= promotion.merchant %>
                      </h3>
                      <h4 class="text-xs text-white">
                        <%= promotion.details %>
                      </h4>
                    </div>
                  </div>
                  <div class="flex flex-row justify-between">
                    <label
                      class="btn basis-1/6 bg-white text-[#362D58] disabled:text-white rounded normal-case border-[#362D58]"
                      for={"claim_reward_modal_#{epp.id}"}
                    >
                      Cancel
                    </label>
                    <label
                      class="btn basis-1/6 text-white bg-[#362D58] disabled:text-white rounded normal-case border-none"
                      for={"claim_reward_modal_#{epp.id}"}
                      phx-click="claim_reward"
                      phx-value-epp_id={epp.id}
                    >
                      Redeem
                    </label>
                  </div>
                </div>
              </div>
            </div>
          <% end %>
        </div>
        <div class="text-center lg:text-left">
          <h2 class="text-3xl text-white font-bold mb-6">Your Stats</h2>

          <div class="mb-4">
            <h3 class="text-white text-md">Total cleanups completed</h3>
            <p class="text-white text-2xl font-bold"><%= @total_cleanup_count %></p>
          </div>
          <div class="pb-4">
            <h3 class="text-white text-md">Completed at this site</h3>
            <p class="text-white text-2xl font-bold"><%= @local_cleanup_count %></p>
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
        epps = Trashy.Promotions.list_event_participant_promotions(
          participant_id
        )

        {:ok,
         assign(socket,
           participant_id: participant_id,
           epps: epps,
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
    %{"epp_id" => epp_id},
    %{assigns: %{participant_id: participant_id}} = socket
  ) do
    epp = Trashy.Promotions.get_event_participant_promotion!(epp_id)

    case epp.is_claimed do
      true ->
        {:noreply, assign(socket, success: false)}

      false ->
        Trashy.Promotions.update_event_participant_promotion(
          epp, %{is_claimed: true}
        )
        epps = Trashy.Promotions.list_event_participant_promotions(
          participant_id
        )
        {:noreply, assign(socket, success: true, epps: epps)}
    end
  end
end

defmodule TrashyWeb.CertificateLive.InvalidCodeError do
  defexception message: "invalid code", plug_status: 404
end
