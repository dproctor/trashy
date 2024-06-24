defmodule Trashy.Repo.Migrations.AddRecurringEvents do
  use Ecto.Migration

  def change do
    alter table(:cleanups) do
      add(:regular_datetime, :naive_datetime)
      add(:enable_recurring_events, :boolean, default: false, null: false)
    end
  end
end
