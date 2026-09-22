defmodule TrashyWeb.DebugController do
  use TrashyWeb, :controller

  alias Trashy.{Cleanups, Events, Promotions}

  # Keep in sync with MerchantLive.urgency/2.
  @amber_after_min 8
  @rose_after_min 15

  @doc """
  Reconstructs what the merchant page showed over the course of a cleanup.

  Query params (both optional):
    * `event_id` – which of the cleanup's events to inspect
    * `at`       – UTC timestamp to replay MerchantLive's event resolution at
                   (defaults to now)
  """
  def merchant(conn, %{"cleanup_id" => cleanup_id} = params) do
    cleanup = Cleanups.get_cleanup!(cleanup_id)
    dbg(cleanup)
    events = Events.list_events_for_cleanup(cleanup)
    now = DateTime.utc_now()
    at = parse_at(params["at"]) || now

    # The exact lookup MerchantLive.load_current_event/1 does, replayed at `at`.
    resolved = List.first(Events.get_matching_events(cleanup.id, at))
    event = pick_event(events, params["event_id"], resolved)

    orders = if event, do: Promotions.list_orders(event.id), else: []

    render(conn, :merchant,
      page_title: "Merchant debug: #{cleanup.neighborhood}",
      cleanup: cleanup,
      events: events,
      event: event,
      resolved: resolved,
      at: at,
      orders: Enum.sort_by(orders, & &1.id),
      participant_count: event && Events.count_participants(event.id),
      timeline: build_timeline(event, orders, now),
      anomalies: anomalies(event, resolved, at, orders)
    )
  end

  # ── Event selection ─────────────────────────────────────────────────

  defp pick_event(events, event_id, resolved) when is_binary(event_id) and event_id != "" do
    Enum.find(events, &(to_string(&1.id) == event_id)) || pick_event(events, nil, resolved)
  end

  defp pick_event(_events, _event_id, %{} = resolved), do: resolved
  defp pick_event([], _event_id, nil), do: nil
  defp pick_event(events, _event_id, nil), do: Enum.max_by(events, &utc(&1.time), DateTime)

  # ── Timeline ────────────────────────────────────────────────────────

  defp build_timeline(nil, _orders, _now), do: []

  defp build_timeline(event, orders, now) do
    start = utc(event.time)

    [%{at: start, kind: :event_start, order: nil, approx: false}]
    |> Kernel.++(Enum.flat_map(orders, &order_entries(&1, now)))
    |> Enum.sort_by(&{DateTime.to_unix(&1.at, :microsecond), kind_rank(&1.kind)})
    |> Enum.map_reduce({0, 0}, fn entry, {open, done} ->
      {open, done} =
        case entry.kind do
          :appeared -> {open + 1, done}
          :completed -> {open - 1, done + 1}
          _ -> {open, done}
        end

      entry = Map.merge(entry, %{open: open, done: done, offset: DateTime.diff(entry.at, start)})
      {entry, {open, done}}
    end)
    |> elem(0)
  end

  defp order_entries(order, now) do
    appeared = utc(order.inserted_at)
    claimed = utc(order.claimed_at)
    # No completed_at column, so updated_at is the best available proxy.
    done_at = if order.completed, do: utc(order.updated_at)

    # When the row changed colour on the merchant's screen (the LiveView only
    # re-renders on its 30s tick, so the merchant saw it up to 30s later).
    urgency =
      for {kind, mins} <- [amber: @amber_after_min, rose: @rose_after_min],
          claimed,
          crossed <- [DateTime.add(claimed, mins * 60, :second)],
          not after?(crossed, now),
          is_nil(done_at) or before?(crossed, done_at),
          do: %{at: crossed, kind: kind, order: order, approx: false}

    completed =
      if done_at, do: [%{at: done_at, kind: :completed, order: order, approx: true}], else: []

    [%{at: appeared, kind: :appeared, order: order, approx: false}] ++ urgency ++ completed
  end

  defp kind_rank(:event_start), do: 0
  defp kind_rank(:appeared), do: 1
  defp kind_rank(:amber), do: 2
  defp kind_rank(:rose), do: 3
  defp kind_rank(:completed), do: 4

  # ── Anomalies ───────────────────────────────────────────────────────

  defp anomalies(nil, _resolved, _at, _orders), do: []

  defp anomalies(event, resolved, at, orders) do
    start = utc(event.time)

    resolution =
      cond do
        is_nil(resolved) ->
          ["At #{fmt(at)} the merchant page would find no event and show “No cleanup scheduled”."]

        resolved.id != event.id ->
          ["At #{fmt(at)} the merchant page would show event ##{resolved.id}, not this one."]

        true ->
          []
      end

    per_order =
      Enum.flat_map(orders, fn o ->
        claimed = utc(o.claimed_at)
        updated = utc(o.updated_at)

        [
          {is_nil(claimed),
           "has no claimed_at, so its wait showed “just now” in grey the whole time"},
          {claimed && before?(claimed, start),
           "was claimed at #{fmt(claimed)}, before the event started"},
          {o.completed && claimed && before?(updated, claimed),
           "is marked done but updated_at is earlier than claimed_at"}
        ]
        |> Enum.filter(&elem(&1, 0))
        |> Enum.map(fn {_, msg} -> "Order ##{o.id} #{msg}." end)
      end)

    resolution ++ per_order
  end

  # ── Helpers ─────────────────────────────────────────────────────────

  defp parse_at(nil), do: nil
  defp parse_at(""), do: nil

  defp parse_at(s) do
    # <input type="datetime-local"> sends "YYYY-MM-DDTHH:MM" with no seconds.
    s = if String.length(s) == 16, do: s <> ":00", else: s

    with {:error, _} <- DateTime.from_iso8601(s),
         {:ok, naive} <- NaiveDateTime.from_iso8601(s) do
      DateTime.from_naive!(naive, "Etc/UTC")
    else
      {:ok, dt, _offset} -> dt
      _ -> nil
    end
  end

  defp utc(nil), do: nil
  defp utc(%DateTime{} = dt), do: dt
  defp utc(%NaiveDateTime{} = n), do: DateTime.from_naive!(n, "Etc/UTC")

  defp before?(a, b), do: DateTime.compare(a, b) == :lt
  defp after?(a, b), do: DateTime.compare(a, b) == :gt

  defp fmt(dt), do: Calendar.strftime(dt, "%b %-d %H:%M:%S UTC")
end
