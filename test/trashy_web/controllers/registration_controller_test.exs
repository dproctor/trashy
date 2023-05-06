defmodule TrashyWeb.RegistrationControllerTest do
  use TrashyWeb.ConnCase

  import Trashy.RegistrationsFixtures

  @create_attrs %{email: "some email", name: "some name"}
  @update_attrs %{email: "some updated email", name: "some updated name"}
  @invalid_attrs %{email: nil, name: nil}

  describe "index" do
    test "lists all registrations", %{conn: conn} do
      conn = get(conn, ~p"/registrations")
      assert html_response(conn, 200) =~ "Listing Registrations"
    end
  end

  describe "new registration" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/registrations/new")
      assert html_response(conn, 200) =~ "New Registration"
    end
  end

  describe "create registration" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/registrations", registration: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/registrations/#{id}"

      conn = get(conn, ~p"/registrations/#{id}")
      assert html_response(conn, 200) =~ "Registration #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/registrations", registration: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Registration"
    end
  end

  describe "edit registration" do
    setup [:create_registration]

    test "renders form for editing chosen registration", %{conn: conn, registration: registration} do
      conn = get(conn, ~p"/registrations/#{registration}/edit")
      assert html_response(conn, 200) =~ "Edit Registration"
    end
  end

  describe "update registration" do
    setup [:create_registration]

    test "redirects when data is valid", %{conn: conn, registration: registration} do
      conn = put(conn, ~p"/registrations/#{registration}", registration: @update_attrs)
      assert redirected_to(conn) == ~p"/registrations/#{registration}"

      conn = get(conn, ~p"/registrations/#{registration}")
      assert html_response(conn, 200) =~ "some updated email"
    end

    test "renders errors when data is invalid", %{conn: conn, registration: registration} do
      conn = put(conn, ~p"/registrations/#{registration}", registration: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Registration"
    end
  end

  describe "delete registration" do
    setup [:create_registration]

    test "deletes chosen registration", %{conn: conn, registration: registration} do
      conn = delete(conn, ~p"/registrations/#{registration}")
      assert redirected_to(conn) == ~p"/registrations"

      assert_error_sent 404, fn ->
        get(conn, ~p"/registrations/#{registration}")
      end
    end
  end

  defp create_registration(_) do
    registration = registration_fixture()
    %{registration: registration}
  end
end
