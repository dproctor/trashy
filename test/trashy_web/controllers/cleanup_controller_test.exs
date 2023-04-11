defmodule TrashyWeb.CleanupControllerTest do
  use TrashyWeb.ConnCase

  import Trashy.CleanupsFixtures

  @create_attrs %{location: "some location"}
  @update_attrs %{location: "some updated location"}
  @invalid_attrs %{location: nil}

  describe "index" do
    test "lists all cleanups", %{conn: conn} do
      conn = get(conn, ~p"/cleanups")
      assert html_response(conn, 200) =~ "Listing Cleanups"
    end
  end

  describe "new cleanup" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/cleanups/new")
      assert html_response(conn, 200) =~ "New Cleanup"
    end
  end

  describe "create cleanup" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/cleanups", cleanup: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/cleanups/#{id}"

      conn = get(conn, ~p"/cleanups/#{id}")
      assert html_response(conn, 200) =~ "Cleanup #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/cleanups", cleanup: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Cleanup"
    end
  end

  describe "edit cleanup" do
    setup [:create_cleanup]

    test "renders form for editing chosen cleanup", %{conn: conn, cleanup: cleanup} do
      conn = get(conn, ~p"/cleanups/#{cleanup}/edit")
      assert html_response(conn, 200) =~ "Edit Cleanup"
    end
  end

  describe "update cleanup" do
    setup [:create_cleanup]

    test "redirects when data is valid", %{conn: conn, cleanup: cleanup} do
      conn = put(conn, ~p"/cleanups/#{cleanup}", cleanup: @update_attrs)
      assert redirected_to(conn) == ~p"/cleanups/#{cleanup}"

      conn = get(conn, ~p"/cleanups/#{cleanup}")
      assert html_response(conn, 200) =~ "some updated location"
    end

    test "renders errors when data is invalid", %{conn: conn, cleanup: cleanup} do
      conn = put(conn, ~p"/cleanups/#{cleanup}", cleanup: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Cleanup"
    end
  end

  describe "delete cleanup" do
    setup [:create_cleanup]

    test "deletes chosen cleanup", %{conn: conn, cleanup: cleanup} do
      conn = delete(conn, ~p"/cleanups/#{cleanup}")
      assert redirected_to(conn) == ~p"/cleanups"

      assert_error_sent 404, fn ->
        get(conn, ~p"/cleanups/#{cleanup}")
      end
    end
  end

  defp create_cleanup(_) do
    cleanup = cleanup_fixture()
    %{cleanup: cleanup}
  end
end
