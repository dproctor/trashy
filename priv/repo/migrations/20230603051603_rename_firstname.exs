defmodule Trashy.Repo.Migrations.RenameFirstname do
  use Ecto.Migration

  def change do
    rename table(:registrations), :name, to: :first_name
    rename table(:users), :name, to: :first_name
    rename table(:event_participants), :name, to: :first_name
  end
end
