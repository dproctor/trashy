defmodule Trashy.Repo.Migrations.AddPromotionDisabled do
  use Ecto.Migration

  def change do
    alter table(:promotions) do
      add(:is_disabled, :boolean, default: false, null: false)
    end
  end
end
