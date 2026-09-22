defmodule TrashyWeb.DebugHTML do
  use TrashyWeb, :html

  embed_templates "debug_html/*"

  def ts(nil), do: "—"
  def ts(%NaiveDateTime{} = n), do: ts(DateTime.from_naive!(n, "Etc/UTC"))
  def ts(%DateTime{} = dt), do: Calendar.strftime(dt, "%b %-d %H:%M:%S")

  def datetime_local(%DateTime{} = dt), do: Calendar.strftime(dt, "%Y-%m-%dT%H:%M")

  # Seconds relative to event start, e.g. "+1h 04m", "+12m 30s", "−3m 05s".
  def offset(secs) do
    sign = if secs < 0, do: "−", else: "+"
    s = abs(secs)
    pad = &String.pad_leading(Integer.to_string(&1), 2, "0")

    if s >= 3600,
      do: "#{sign}#{div(s, 3600)}h #{pad.(div(rem(s, 3600), 60))}m",
      else: "#{sign}#{div(s, 60)}m #{pad.(rem(s, 60))}s"
  end

  def describe(:event_start), do: "Event starts"
  def describe(:appeared), do: "Order appears"
  def describe(:amber), do: "Wait turns amber"
  def describe(:rose), do: "Wait turns red"
  def describe(:completed), do: "Marked done"

  def kind_class(:event_start), do: "font-semibold text-stone-900"
  def kind_class(:amber), do: "text-amber-700"
  def kind_class(:rose), do: "text-rose-700"
  def kind_class(:completed), do: "text-emerald-700"
  def kind_class(_), do: "text-stone-700"

  # Mirrors MerchantLive's private helpers so labels match what the merchant saw.
  def order_label(%{choice: c}) when c not in [nil, ""], do: c
  def order_label(%{promotion: %{details: d}}), do: d
  def order_label(_), do: "—"

  def participant_name(%{event_participant: %{first_name: f, last_name: l}}), do: "#{f} #{l}"
  def participant_name(_), do: "—"
end
