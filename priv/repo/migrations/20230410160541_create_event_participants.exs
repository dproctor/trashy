defmodule Trashy.Repo.Migrations.CreateEventParticipants do
  use Ecto.Migration

  def change do
    create table(:event_participants) do
      add(:name, :string)
      add(:email, :string)
      add(:user_id, references(:users, on_delete: :nothing))
      add(:event_id, references(:events, on_delete: :nothing))
      add(:code, :string, default: fragment("gen_random_uuid()::text"))

      timestamps()
    end

    create(index(:event_participants, [:user_id]))
    create(index(:event_participants, [:event_id]))
  end
end
