defmodule TrashyWeb.EventParticipantControllerTest do
  use TrashyWeb.ConnCase

  import Trashy.EventsFixtures

  @create_attrs %{email: "some email", name: "some name"}
  @update_attrs %{email: "some updated email", name: "some updated name"}
  @invalid_attrs %{email: nil, name: nil}

  describe "index" do
    test "lists all event_participants", %{conn: conn} do
      conn = get(conn, ~p"/event_participants")
      assert html_response(conn, 200) =~ "Listing Event participants"
    end
  end

  describe "new event_participant" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/event_participants/new")
      assert html_response(conn, 200) =~ "New Event participant"
    end
  end

  describe "create event_participant" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/event_participants", event_participant: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/event_participants/#{id}"

      conn = get(conn, ~p"/event_participants/#{id}")
      assert html_response(conn, 200) =~ "Event participant #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/event_participants", event_participant: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Event participant"
    end
  end

  describe "edit event_participant" do
    setup [:create_event_participant]

    test "renders form for editing chosen event_participant", %{conn: conn, event_participant: event_participant} do
      conn = get(conn, ~p"/event_participants/#{event_participant}/edit")
      assert html_response(conn, 200) =~ "Edit Event participant"
    end
  end

  describe "update event_participant" do
    setup [:create_event_participant]

    test "redirects when data is valid", %{conn: conn, event_participant: event_participant} do
      conn = put(conn, ~p"/event_participants/#{event_participant}", event_participant: @update_attrs)
      assert redirected_to(conn) == ~p"/event_participants/#{event_participant}"

      conn = get(conn, ~p"/event_participants/#{event_participant}")
      assert html_response(conn, 200) =~ "some updated email"
    end

    test "renders errors when data is invalid", %{conn: conn, event_participant: event_participant} do
      conn = put(conn, ~p"/event_participants/#{event_participant}", event_participant: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Event participant"
    end
  end

  describe "delete event_participant" do
    setup [:create_event_participant]

    test "deletes chosen event_participant", %{conn: conn, event_participant: event_participant} do
      conn = delete(conn, ~p"/event_participants/#{event_participant}")
      assert redirected_to(conn) == ~p"/event_participants"

      assert_error_sent 404, fn ->
        get(conn, ~p"/event_participants/#{event_participant}")
      end
    end
  end

  defp create_event_participant(_) do
    event_participant = event_participant_fixture()
    %{event_participant: event_participant}
  end
end
