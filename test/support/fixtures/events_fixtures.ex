defmodule Trashy.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Trashy.Events` context.
  """

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    {:ok, event} =
      attrs
      |> Enum.into(%{
        time: ~U[2023-04-09 16:05:00Z]
      })
      |> Trashy.Events.create_event()

    event
  end

  @doc """
  Generate a event_participant.
  """
  def event_participant_fixture(attrs \\ %{}) do
    {:ok, event_participant} =
      attrs
      |> Enum.into(%{
        email: "some email",
        name: "some name"
      })
      |> Trashy.Events.create_event_participant()

    event_participant
  end
end
