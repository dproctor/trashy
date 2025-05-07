defmodule Trashy.CronWorker do
  use GenServer

  alias Trashy.Events

  def start_link(period_millis) do
    GenServer.start_link(__MODULE__, period_millis)
  end

  @impl true
  def init(period_millis) do
    schedule_next(period_millis)
    {:ok, period_millis}
  end

  @impl true
  def handle_info(:create_recurring_events, period_millis) do
    Events.create_new_recurring_events(1)

    schedule_next(period_millis)

    {:noreply, period_millis}
  end

  def schedule_next(period_millis) do
    Process.send_after(self(), :create_recurring_events, period_millis)
  end
end
