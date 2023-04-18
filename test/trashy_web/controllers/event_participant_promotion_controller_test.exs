defmodule TrashyWeb.EventParticipantPromotionControllerTest do
  use TrashyWeb.ConnCase

  import Trashy.PromotionsFixtures

  @create_attrs %{is_claimed: true}
  @update_attrs %{is_claimed: false}
  @invalid_attrs %{is_claimed: nil}

  describe "index" do
    test "lists all event_participant_promotions", %{conn: conn} do
      conn = get(conn, ~p"/event_participant_promotions")
      assert html_response(conn, 200) =~ "Listing Event participant promotions"
    end
  end

  describe "new event_participant_promotion" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/event_participant_promotions/new")
      assert html_response(conn, 200) =~ "New Event participant promotion"
    end
  end

  describe "create event_participant_promotion" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/event_participant_promotions", event_participant_promotion: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/event_participant_promotions/#{id}"

      conn = get(conn, ~p"/event_participant_promotions/#{id}")
      assert html_response(conn, 200) =~ "Event participant promotion #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/event_participant_promotions", event_participant_promotion: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Event participant promotion"
    end
  end

  describe "edit event_participant_promotion" do
    setup [:create_event_participant_promotion]

    test "renders form for editing chosen event_participant_promotion", %{conn: conn, event_participant_promotion: event_participant_promotion} do
      conn = get(conn, ~p"/event_participant_promotions/#{event_participant_promotion}/edit")
      assert html_response(conn, 200) =~ "Edit Event participant promotion"
    end
  end

  describe "update event_participant_promotion" do
    setup [:create_event_participant_promotion]

    test "redirects when data is valid", %{conn: conn, event_participant_promotion: event_participant_promotion} do
      conn = put(conn, ~p"/event_participant_promotions/#{event_participant_promotion}", event_participant_promotion: @update_attrs)
      assert redirected_to(conn) == ~p"/event_participant_promotions/#{event_participant_promotion}"

      conn = get(conn, ~p"/event_participant_promotions/#{event_participant_promotion}")
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, event_participant_promotion: event_participant_promotion} do
      conn = put(conn, ~p"/event_participant_promotions/#{event_participant_promotion}", event_participant_promotion: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Event participant promotion"
    end
  end

  describe "delete event_participant_promotion" do
    setup [:create_event_participant_promotion]

    test "deletes chosen event_participant_promotion", %{conn: conn, event_participant_promotion: event_participant_promotion} do
      conn = delete(conn, ~p"/event_participant_promotions/#{event_participant_promotion}")
      assert redirected_to(conn) == ~p"/event_participant_promotions"

      assert_error_sent 404, fn ->
        get(conn, ~p"/event_participant_promotions/#{event_participant_promotion}")
      end
    end
  end

  defp create_event_participant_promotion(_) do
    event_participant_promotion = event_participant_promotion_fixture()
    %{event_participant_promotion: event_participant_promotion}
  end
end
