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
      |> assign(pending_count: 0, done_count: 0, participant_count: 0, tally: [])
      |> load_current_event()

    {:ok, socket}
  end

  # ── Event resolution ────────────────────────────────────────────────

  # Already resolved — cheap no-op on every subsequent tick. This guard is
  # load-bearing on LiveView 0.18: stream/3 can only be called once per
  # stream name per socket (no reset: option until 0.19).
  defp load_current_event(%{assigns: %{event: %{}}} = socket), do: socket
  defp load_current_event(%{assigns: %{current_user: nil}} = socket), do: socket

  defp load_current_event(socket) do
    with [cleanup | _] <- Cleanups.list_cleanups_for_user(socket.assigns.current_user),
         [event | _] <- Events.get_matching_events(cleanup.id, DateTime.utc_now()) do
      if connected?(socket), do: Promotions.subscribe_to_orders(event.id)

      orders = Promotions.list_orders(event.id)
      {pending, done} = Enum.split_with(orders, &(!&1.completed))

      socket
      |> assign(:event, event)
      |> assign(:cleanup, cleanup)
      |> assign(:participant_count, Events.count_participants(event.id))
      |> assign(:orders, Map.new(orders, &{&1.id, &1}))
      |> assign_summary()
      |> stream(:pending, pending)
      |> stream(:done, Enum.reverse(done))
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
     |> place(order)
     |> assign_summary()}
  end

  def handle_info(:tick, socket) do
    {:noreply,
     socket
     |> assign(:now, DateTime.utc_now())
     |> load_current_event()}
  end

  # Move a row into the correct stream. stream_delete on an absent item is a
  # no-op, so this handles both brand-new orders and completion toggles.
  defp place(socket, %{completed: true} = order) do
    socket
    |> stream_delete(:pending, order)
    |> stream_insert(:done, order, at: 0)
  end

  defp place(socket, order) do
    socket
    |> stream_delete(:done, order)
    |> stream_insert(:pending, order)
  end

  # ── Derived state ───────────────────────────────────────────────────

  defp assign_summary(socket) do
    {pending, done} =
      socket.assigns.orders
      |> Map.values()
      |> Enum.split_with(&(!&1.completed))

    socket
    |> assign(:pending_count, length(pending))
    |> assign(:done_count, length(done))
    |> assign(:tally, tally(pending))
  end

  defp tally(pending) do
    pending
    |> Enum.group_by(&{&1.promotion.icon, order_label(&1)})
    |> Enum.map(fn {{icon, label}, list} ->
      %{icon: icon, label: label, count: length(list)}
    end)
    |> Enum.sort_by(& &1.count, :desc)
  end

  # Promotions without a choice list are redeemed with choice == nil.
  defp order_label(%{choice: c}) when c not in [nil, ""], do: c
  defp order_label(%{promotion: promotion}), do: promotion.details

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

  defp urgency(mins) when mins >= 15, do: "text-rose-600"
  defp urgency(mins) when mins >= 8, do: "text-amber-600"
  defp urgency(_), do: "text-stone-400"
end
