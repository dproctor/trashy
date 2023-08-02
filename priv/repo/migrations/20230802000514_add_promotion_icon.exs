defmodule Trashy.Repo.Migrations.AddPromotionIcon do
  use Ecto.Migration

  def change do
    alter table(:promotions) do
      add(:icon, :string)
    end
  end
end
