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
end
