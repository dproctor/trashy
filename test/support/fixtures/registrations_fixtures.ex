defmodule Trashy.RegistrationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Trashy.Registrations` context.
  """

  @doc """
  Generate a registration.
  """
  def registration_fixture(attrs \\ %{}) do
    {:ok, registration} =
      attrs
      |> Enum.into(%{
        email: "some email",
        name: "some name"
      })
      |> Trashy.Registrations.create_registration()

    registration
  end
end
