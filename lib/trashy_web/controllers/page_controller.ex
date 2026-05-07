defmodule TrashyWeb.PageController do
  use TrashyWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def privacy(conn, _params) do
    render(conn, :privacy, layout: false)
  end

  def organizer(conn, _params) do
    render(conn, :organizer)
  end

  def organizer_not_authorized(conn, _params) do
    render(conn, :organizer_not_authorized)
  end

  def admin(conn, _params) do
    render(conn, :admin)
  end

  def merchant(conn, _params) do
    with [cleanup | _] <- Trashy.Cleanups.list_cleanups_for_user(conn.assigns.current_user),
         [event | _] <- Trashy.Events.get_matching_events(cleanup.id, DateTime.utc_now()) do
      cleanup = Trashy.Cleanups.get_cleanup_with_preloads(cleanup.id)
      participants = Trashy.Events.list_event_participants_for_event(event)

      promotions =
        for(
          promotion <- Trashy.Promotions.list_promotions_for_cleanup(cleanup),
          into: %{}
        ) do
          {promotion.id, promotion}
        end

      participants_by_id = Map.new(participants, &{&1.id, &1})

      # Map each participant to a list of claimed promotions.
      participant_epps_claimed =
        Map.new(participants, fn participant ->
          epps = Trashy.Promotions.list_event_participant_promotions(participant.id)
          {participant.id, Enum.filter(epps, & &1.is_claimed)}
        end)

      promotion_choice_claims =
        participant_epps_claimed
        |> Map.values()
        |> Enum.concat()
        |> Enum.group_by(& &1.promotion, fn epp ->
          participant = participants_by_id[epp.event_participant_id]

          %{
            choice: epp.choice,
            notes: epp.notes,
            name:
              "#{participant.first_name || ""} #{participant.last_name || ""}" |> String.trim(),
            email: participant.email
          }
        end)
        |> Map.new(fn {promotion, entries} ->
          summary =
            entries
            |> Enum.group_by(&{&1.choice, &1.notes})
            |> Map.new(fn {{choice, notes}, items} ->
              {{choice, notes},
               %{
                 count: length(items),
                 names: items |> Enum.map(& &1.name) |> Enum.join(", "),
                 emails: items |> Enum.map(& &1.email) |> Enum.join(", ")
               }}
            end)

          {promotion, summary}
        end)

      render(conn, :merchant,
        event: event,
        cleanup: cleanup,
        event_participants: participants,
        promotions: promotions,
        participant_epps_claimed: participant_epps_claimed,
        promotion_choice_claims: promotion_choice_claims
      )
    else
      _ -> render(conn, :merchant_no_event)
    end
  end
end
