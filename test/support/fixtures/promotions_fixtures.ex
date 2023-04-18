defmodule Trashy.PromotionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Trashy.Promotions` context.
  """

  @doc """
  Generate a promotion.
  """
  def promotion_fixture(attrs \\ %{}) do
    {:ok, promotion} =
      attrs
      |> Enum.into(%{
        details: "some details",
        merchant: "some merchant"
      })
      |> Trashy.Promotions.create_promotion()

    promotion
  end

  @doc """
  Generate a event_participant_promotion.
  """
  def event_participant_promotion_fixture(attrs \\ %{}) do
    {:ok, event_participant_promotion} =
      attrs
      |> Enum.into(%{
        is_claimed: true
      })
      |> Trashy.Promotions.create_event_participant_promotion()

    event_participant_promotion
  end
end
