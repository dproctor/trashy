defmodule Trashy.Registrations.Registration do
  use Ecto.Schema
  import Ecto.Changeset

  schema "registrations" do
    field :email, :string
    field :name, :string
    field :cleanup_id, :id

    timestamps()
  end

  @doc false
  def changeset(registration, attrs) do
    registration
    |> cast(attrs, [:name, :email, :cleanup_id])
    |> validate_required([:name, :email, :cleanup_id])
  end
end
