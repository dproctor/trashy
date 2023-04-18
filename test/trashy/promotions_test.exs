defmodule Trashy.PromotionsTest do
  use Trashy.DataCase

  alias Trashy.Promotions

  describe "promotions" do
    alias Trashy.Promotions.Promotion

    import Trashy.PromotionsFixtures

    @invalid_attrs %{details: nil, merchant: nil}

    test "list_promotions/0 returns all promotions" do
      promotion = promotion_fixture()
      assert Promotions.list_promotions() == [promotion]
    end

    test "get_promotion!/1 returns the promotion with given id" do
      promotion = promotion_fixture()
      assert Promotions.get_promotion!(promotion.id) == promotion
    end

    test "create_promotion/1 with valid data creates a promotion" do
      valid_attrs = %{details: "some details", merchant: "some merchant"}

      assert {:ok, %Promotion{} = promotion} = Promotions.create_promotion(valid_attrs)
      assert promotion.details == "some details"
      assert promotion.merchant == "some merchant"
    end

    test "create_promotion/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Promotions.create_promotion(@invalid_attrs)
    end

    test "update_promotion/2 with valid data updates the promotion" do
      promotion = promotion_fixture()
      update_attrs = %{details: "some updated details", merchant: "some updated merchant"}

      assert {:ok, %Promotion{} = promotion} = Promotions.update_promotion(promotion, update_attrs)
      assert promotion.details == "some updated details"
      assert promotion.merchant == "some updated merchant"
    end

    test "update_promotion/2 with invalid data returns error changeset" do
      promotion = promotion_fixture()
      assert {:error, %Ecto.Changeset{}} = Promotions.update_promotion(promotion, @invalid_attrs)
      assert promotion == Promotions.get_promotion!(promotion.id)
    end

    test "delete_promotion/1 deletes the promotion" do
      promotion = promotion_fixture()
      assert {:ok, %Promotion{}} = Promotions.delete_promotion(promotion)
      assert_raise Ecto.NoResultsError, fn -> Promotions.get_promotion!(promotion.id) end
    end

    test "change_promotion/1 returns a promotion changeset" do
      promotion = promotion_fixture()
      assert %Ecto.Changeset{} = Promotions.change_promotion(promotion)
    end
  end

  describe "event_participant_promotions" do
    alias Trashy.Promotions.EventParticipantPromotion

    import Trashy.PromotionsFixtures

    @invalid_attrs %{is_claimed: nil}

    test "list_event_participant_promotions/0 returns all event_participant_promotions" do
      event_participant_promotion = event_participant_promotion_fixture()
      assert Promotions.list_event_participant_promotions() == [event_participant_promotion]
    end

    test "get_event_participant_promotion!/1 returns the event_participant_promotion with given id" do
      event_participant_promotion = event_participant_promotion_fixture()
      assert Promotions.get_event_participant_promotion!(event_participant_promotion.id) == event_participant_promotion
    end

    test "create_event_participant_promotion/1 with valid data creates a event_participant_promotion" do
      valid_attrs = %{is_claimed: true}

      assert {:ok, %EventParticipantPromotion{} = event_participant_promotion} = Promotions.create_event_participant_promotion(valid_attrs)
      assert event_participant_promotion.is_claimed == true
    end

    test "create_event_participant_promotion/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Promotions.create_event_participant_promotion(@invalid_attrs)
    end

    test "update_event_participant_promotion/2 with valid data updates the event_participant_promotion" do
      event_participant_promotion = event_participant_promotion_fixture()
      update_attrs = %{is_claimed: false}

      assert {:ok, %EventParticipantPromotion{} = event_participant_promotion} = Promotions.update_event_participant_promotion(event_participant_promotion, update_attrs)
      assert event_participant_promotion.is_claimed == false
    end

    test "update_event_participant_promotion/2 with invalid data returns error changeset" do
      event_participant_promotion = event_participant_promotion_fixture()
      assert {:error, %Ecto.Changeset{}} = Promotions.update_event_participant_promotion(event_participant_promotion, @invalid_attrs)
      assert event_participant_promotion == Promotions.get_event_participant_promotion!(event_participant_promotion.id)
    end

    test "delete_event_participant_promotion/1 deletes the event_participant_promotion" do
      event_participant_promotion = event_participant_promotion_fixture()
      assert {:ok, %EventParticipantPromotion{}} = Promotions.delete_event_participant_promotion(event_participant_promotion)
      assert_raise Ecto.NoResultsError, fn -> Promotions.get_event_participant_promotion!(event_participant_promotion.id) end
    end

    test "change_event_participant_promotion/1 returns a event_participant_promotion changeset" do
      event_participant_promotion = event_participant_promotion_fixture()
      assert %Ecto.Changeset{} = Promotions.change_event_participant_promotion(event_participant_promotion)
    end
  end
end
