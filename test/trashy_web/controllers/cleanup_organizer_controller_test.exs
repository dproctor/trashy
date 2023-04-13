defmodule TrashyWeb.CleanupOrganizerControllerTest do
  use TrashyWeb.ConnCase

  import Trashy.CleanupsFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  describe "index" do
    test "lists all cleanup_organizers", %{conn: conn} do
      conn = get(conn, ~p"/cleanup_organizers")
      assert html_response(conn, 200) =~ "Listing Cleanup organizers"
    end
  end

  describe "new cleanup_organizer" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/cleanup_organizers/new")
      assert html_response(conn, 200) =~ "New Cleanup organizer"
    end
  end

  describe "create cleanup_organizer" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/cleanup_organizers", cleanup_organizer: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/cleanup_organizers/#{id}"

      conn = get(conn, ~p"/cleanup_organizers/#{id}")
      assert html_response(conn, 200) =~ "Cleanup organizer #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/cleanup_organizers", cleanup_organizer: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Cleanup organizer"
    end
  end

  describe "edit cleanup_organizer" do
    setup [:create_cleanup_organizer]

    test "renders form for editing chosen cleanup_organizer", %{conn: conn, cleanup_organizer: cleanup_organizer} do
      conn = get(conn, ~p"/cleanup_organizers/#{cleanup_organizer}/edit")
      assert html_response(conn, 200) =~ "Edit Cleanup organizer"
    end
  end

  describe "update cleanup_organizer" do
    setup [:create_cleanup_organizer]

    test "redirects when data is valid", %{conn: conn, cleanup_organizer: cleanup_organizer} do
      conn = put(conn, ~p"/cleanup_organizers/#{cleanup_organizer}", cleanup_organizer: @update_attrs)
      assert redirected_to(conn) == ~p"/cleanup_organizers/#{cleanup_organizer}"

      conn = get(conn, ~p"/cleanup_organizers/#{cleanup_organizer}")
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, cleanup_organizer: cleanup_organizer} do
      conn = put(conn, ~p"/cleanup_organizers/#{cleanup_organizer}", cleanup_organizer: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Cleanup organizer"
    end
  end

  describe "delete cleanup_organizer" do
    setup [:create_cleanup_organizer]

    test "deletes chosen cleanup_organizer", %{conn: conn, cleanup_organizer: cleanup_organizer} do
      conn = delete(conn, ~p"/cleanup_organizers/#{cleanup_organizer}")
      assert redirected_to(conn) == ~p"/cleanup_organizers"

      assert_error_sent 404, fn ->
        get(conn, ~p"/cleanup_organizers/#{cleanup_organizer}")
      end
    end
  end

  defp create_cleanup_organizer(_) do
    cleanup_organizer = cleanup_organizer_fixture()
    %{cleanup_organizer: cleanup_organizer}
  end
end
