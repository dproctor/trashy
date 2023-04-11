defmodule TrashyWeb.PromotionControllerTest do
  use TrashyWeb.ConnCase

  import Trashy.PromotionsFixtures

  @create_attrs %{details: "some details", merchant: "some merchant"}
  @update_attrs %{details: "some updated details", merchant: "some updated merchant"}
  @invalid_attrs %{details: nil, merchant: nil}

  describe "index" do
    test "lists all promotions", %{conn: conn} do
      conn = get(conn, ~p"/promotions")
      assert html_response(conn, 200) =~ "Listing Promotions"
    end
  end

  describe "new promotion" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/promotions/new")
      assert html_response(conn, 200) =~ "New Promotion"
    end
  end

  describe "create promotion" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/promotions", promotion: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/promotions/#{id}"

      conn = get(conn, ~p"/promotions/#{id}")
      assert html_response(conn, 200) =~ "Promotion #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/promotions", promotion: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Promotion"
    end
  end

  describe "edit promotion" do
    setup [:create_promotion]

    test "renders form for editing chosen promotion", %{conn: conn, promotion: promotion} do
      conn = get(conn, ~p"/promotions/#{promotion}/edit")
      assert html_response(conn, 200) =~ "Edit Promotion"
    end
  end

  describe "update promotion" do
    setup [:create_promotion]

    test "redirects when data is valid", %{conn: conn, promotion: promotion} do
      conn = put(conn, ~p"/promotions/#{promotion}", promotion: @update_attrs)
      assert redirected_to(conn) == ~p"/promotions/#{promotion}"

      conn = get(conn, ~p"/promotions/#{promotion}")
      assert html_response(conn, 200) =~ "some updated details"
    end

    test "renders errors when data is invalid", %{conn: conn, promotion: promotion} do
      conn = put(conn, ~p"/promotions/#{promotion}", promotion: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Promotion"
    end
  end

  describe "delete promotion" do
    setup [:create_promotion]

    test "deletes chosen promotion", %{conn: conn, promotion: promotion} do
      conn = delete(conn, ~p"/promotions/#{promotion}")
      assert redirected_to(conn) == ~p"/promotions"

      assert_error_sent 404, fn ->
        get(conn, ~p"/promotions/#{promotion}")
      end
    end
  end

  defp create_promotion(_) do
    promotion = promotion_fixture()
    %{promotion: promotion}
  end
end
