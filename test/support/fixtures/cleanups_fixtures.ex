defmodule Trashy.CleanupsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Trashy.Cleanups` context.
  """

  @doc """
  Generate a cleanup.
  """
  def cleanup_fixture(attrs \\ %{}) do
    {:ok, cleanup} =
      attrs
      |> Enum.into(%{
        location: "some location"
      })
      |> Trashy.Cleanups.create_cleanup()

    cleanup
  end

  @doc """
  Generate a cleanup_organizer.
  """
  def cleanup_organizer_fixture(attrs \\ %{}) do
    {:ok, cleanup_organizer} =
      attrs
      |> Enum.into(%{

      })
      |> Trashy.Cleanups.create_cleanup_organizer()

    cleanup_organizer
  end
end
