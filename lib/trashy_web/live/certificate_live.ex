defmodule TrashyWeb.CertificateLive do
  use TrashyWeb, :live_view

  def render(assigns) do
    ~H"""
    <%= if Enum.member?([1, 5, 10, 25, 50, 100, 200, 300, 500, 1000], @total_cleanup_count) do %>
      <div id="page-load" phx-hook="DisplayConfetti"></div>
    <% end %>
    <.flash kind={:error} title="Error!" flash={@flash} />
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
            <% promotion = epp.promotion
            choices? = promotion.choices != [] %>
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
                <h3 class="basis-1/6 text-white text-center">
                  <%= epp.choice || "Redeemed" %>
                </h3>
              <% else %>
                <label
                  class="btn basis-1/6 bg-white text-[#362D58] rounded normal-case border-none"
                  for={"claim_reward_modal_#{epp.id}"}
                >
                  Redeem
                </label>
              <% end %>
            </div>
            <input
              type="checkbox"
              id={"claim_reward_modal_#{epp.id}"}
              class="modal-toggle"
              phx-hook="ModalCheckboxHandlers"
            />
            <.form
              :let={f}
              for={
                to_form(
                  Trashy.Promotions.change_event_participant_promotion(epp),
                  as: "epp_chg"
                )
              }
              id={"claim_reward_form_#{epp.id}"}
              class="modal"
              phx-submit="claim_reward"
            >
              <.input type="hidden" field={f[:id]} />
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
                      <%= if !choices? do %>
                        <h4 class="text-xs text-white">
                          <%= promotion.details %>
                        </h4>
                      <% else %>
                      <% end %>
                    </div>
                  </div>
                  <%= if choices? do %>
                    <div class="flex flex-col bg-[#362D58] p-4 rounded">
                      <.input
                        type="select"
                        field={f[:choice]}
                        options={promotion.choices}
                        label={promotion.details}
                        prompt=""
                        required
                      />
                    </div>
                  <% end %>
                  <%= if promotion.show_notes_field do %>
                    <div class="flex flex-col bg-[#362D58] p-4 rounded">
                      <.input
                        type="text"
                        field={f[:notes]}
                        label="Notes for merchant (e.g. dietary preferences)"
                      />
                    </div>
                  <% end %>
                  <div class="flex flex-row justify-between">
                    <label
                      class="btn basis-1/6 bg-white text-[#362D58] disabled:text-white rounded normal-case border-[#362D58]"
                      for={"claim_reward_modal_#{epp.id}"}
                    >
                      Cancel
                    </label>
                    <.button
                      type="submit"
                      class="btn basis-1/6 text-white bg-[#362D58] disabled:text-white rounded normal-case border-none"
                    >
                      Redeem
                    </.button>
                  </div>
                </div>
              </div>
            </.form>
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
        epps = Trashy.Promotions.list_event_participant_promotions(participant_id)

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
        %{"epp_chg" => epp_chg},
        %{assigns: %{participant_id: participant_id}} = socket
      ) do
    epp = Trashy.Promotions.get_event_participant_promotion!(epp_chg["id"])

    if epp.is_claimed do
      {
        :noreply,
        socket
        |> put_flash(:error, "This reward has already been redeemed.")
      }
    else
      {:ok, _} =
        Trashy.Promotions.update_event_participant_promotion(
          epp,
          Map.merge(
            # Filter only to allowed keys.
            Map.take(epp_chg, ["choice", "notes"]),
            # Always mark as claimed.
            %{"is_claimed" => true}
          )
        )

      epps = Trashy.Promotions.list_event_participant_promotions(participant_id)

      {
        :noreply,
        socket
        |> assign(epps: epps)
        |> push_event("js:modal:#claim_reward_modal_#{epp.id}", %{
          # Close the modal.
          open: false
        })
      }
    end
  end
end

defmodule TrashyWeb.CertificateLive.InvalidCodeError do
  defexception message: "invalid code", plug_status: 404
end
