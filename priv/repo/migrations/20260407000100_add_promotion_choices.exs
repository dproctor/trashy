defmodule Trashy.Repo.Migrations.AddPromotionChoices do
  use Ecto.Migration

  def change do
    alter table(:promotions) do
      add(:choices, {:array, :string}, default: [], null: [])
    end
  end
end
