# lib/trashy_web/live/merchant_live.ex
defmodule TrashyWeb.MerchantLive do
  use TrashyWeb, :live_view

  alias Trashy.{Cleanups, Events, Promotions}

  @tick_ms :timer.seconds(30)

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: :timer.send_interval(@tick_ms, self(), :tick)

    socket =
      socket
      |> assign(:now, DateTime.utc_now())
      |> assign(event: nil, cleanup: nil, orders: %{})
      |> assign(pending_count: 0, done_count: 0, participant_count: 0, rows: [])
      |> load_current_event()

    {:ok, socket}
  end

  # ── Event resolution ────────────────────────────────────────────────

  # Already resolved — cheap no-op on every subsequent tick. Still load-bearing:
  # without it the tick would re-subscribe to the same topic over and over.
  defp load_current_event(%{assigns: %{event: %{}}} = socket), do: socket
  defp load_current_event(%{assigns: %{current_user: nil}} = socket), do: socket

  defp load_current_event(socket) do
    with [cleanup | _] <- Cleanups.list_cleanups_for_user(socket.assigns.current_user),
         [event | _] <- Events.get_matching_events(cleanup.id, DateTime.utc_now()) do
      if connected?(socket), do: Promotions.subscribe_to_orders(event.id)

      orders = Promotions.list_orders(event.id)

      socket
      |> assign(:event, event)
      |> assign(:cleanup, cleanup)
      |> assign(:participant_count, Events.count_participants(event.id))
      |> assign(:orders, Map.new(orders, &{&1.id, &1}))
      |> assign_summary()
    else
      _ -> socket
    end
  end

  # ── Events ──────────────────────────────────────────────────────────

  @impl true
  def handle_event("toggle_complete", %{"id" => id}, socket) do
    order = Map.fetch!(socket.assigns.orders, String.to_integer(id))

    case Promotions.set_order_completed(order, !order.completed) do
      {:ok, _epp} -> {:noreply, socket}
      {:error, _} -> {:noreply, put_flash(socket, :error, "Couldn't update that order.")}
    end
  end

  @impl true
  def handle_info({event, order}, socket) when event in [:order_created, :order_updated] do
    {:noreply,
     socket
     |> update(:orders, &Map.put(&1, order.id, order))
     |> assign_summary()}
  end

  def handle_info(:tick, socket) do
    {:noreply,
     socket
     |> assign(:now, DateTime.utc_now())
     |> load_current_event()}
  end

  # ── Derived state ───────────────────────────────────────────────────

  # One flat list, sorted by id, so a row never moves. Completing an order only
  # changes how it is styled — hence no streams: the whole table is a plain
  # comprehension over @rows. Fine at one-cleanup scale (tens of orders).
  defp assign_summary(socket) do
    rows =
      socket.assigns.orders
      |> Map.values()
      |> Enum.sort_by(& &1.id)

    {pending, done} = Enum.split_with(rows, &(!&1.completed))

    socket
    |> assign(:rows, rows)
    |> assign(:pending_count, length(pending))
    |> assign(:done_count, length(done))
  end

  # Promotions without a choice list are redeemed with choice == nil.
  defp order_label(%{choice: c}) when c not in [nil, ""], do: c
  defp order_label(%{promotion: promotion}), do: promotion.details

  defp participant_name(%{event_participant: p}), do: "#{p.first_name} #{p.last_name}"

  # ── Time helpers ────────────────────────────────────────────────────

  defp minutes_waiting(nil, _now), do: 0
  defp minutes_waiting(claimed_at, now), do: DateTime.diff(now, claimed_at, :minute)

  defp waited(claimed_at, now) do
    case minutes_waiting(claimed_at, now) do
      m when m < 1 -> "just now"
      m when m < 60 -> "#{m}m"
      m -> "#{div(m, 60)}h #{rem(m, 60)}m"
    end
  end

  # Completed rows never look urgent — the wait is over, it's just a record.
  defp urgency(%{completed: true}, _now), do: "text-stone-300"

  defp urgency(order, now) do
    case minutes_waiting(order.claimed_at, now) do
      m when m >= 15 -> "text-rose-600"
      m when m >= 8 -> "text-amber-600"
      _ -> "text-stone-400"
    end
  end
end
