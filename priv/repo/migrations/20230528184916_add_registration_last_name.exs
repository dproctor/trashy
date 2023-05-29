defmodule Trashy.Repo.Migrations.AddRegistrationLastName do
  use Ecto.Migration

  def change do
    alter table(:registrations) do
      add :last_name, :string
    end
  end
end
