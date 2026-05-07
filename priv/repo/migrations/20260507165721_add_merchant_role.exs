defmodule Trashy.Repo.Migrations.AddMerchantRole do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_merchant, :boolean
    end
  end
end
