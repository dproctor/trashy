defmodule Trashy.EventsTest do
  use Trashy.DataCase

  alias Trashy.Events

  describe "events" do
    alias Trashy.Events.Event

    import Trashy.EventsFixtures

    @invalid_attrs %{time: nil}

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Events.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Events.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      valid_attrs = %{time: ~U[2023-04-09 16:05:00Z]}

      assert {:ok, %Event{} = event} = Events.create_event(valid_attrs)
      assert event.time == ~U[2023-04-09 16:05:00Z]
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()
      update_attrs = %{time: ~U[2023-04-10 16:05:00Z]}

      assert {:ok, %Event{} = event} = Events.update_event(event, update_attrs)
      assert event.time == ~U[2023-04-10 16:05:00Z]
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update_event(event, @invalid_attrs)
      assert event == Events.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Events.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Events.change_event(event)
    end
  end

  describe "event_participants" do
    alias Trashy.Events.EventParticipant

    import Trashy.EventsFixtures

    @invalid_attrs %{email: nil, name: nil}

    test "list_event_participants/0 returns all event_participants" do
      event_participant = event_participant_fixture()
      assert Events.list_event_participants() == [event_participant]
    end

    test "get_event_participant!/1 returns the event_participant with given id" do
      event_participant = event_participant_fixture()
      assert Events.get_event_participant!(event_participant.id) == event_participant
    end

    test "create_event_participant/1 with valid data creates a event_participant" do
      valid_attrs = %{email: "some email", name: "some name"}

      assert {:ok, %EventParticipant{} = event_participant} = Events.create_event_participant(valid_attrs)
      assert event_participant.email == "some email"
      assert event_participant.name == "some name"
    end

    test "create_event_participant/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event_participant(@invalid_attrs)
    end

    test "update_event_participant/2 with valid data updates the event_participant" do
      event_participant = event_participant_fixture()
      update_attrs = %{email: "some updated email", name: "some updated name"}

      assert {:ok, %EventParticipant{} = event_participant} = Events.update_event_participant(event_participant, update_attrs)
      assert event_participant.email == "some updated email"
      assert event_participant.name == "some updated name"
    end

    test "update_event_participant/2 with invalid data returns error changeset" do
      event_participant = event_participant_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update_event_participant(event_participant, @invalid_attrs)
      assert event_participant == Events.get_event_participant!(event_participant.id)
    end

    test "delete_event_participant/1 deletes the event_participant" do
      event_participant = event_participant_fixture()
      assert {:ok, %EventParticipant{}} = Events.delete_event_participant(event_participant)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event_participant!(event_participant.id) end
    end

    test "change_event_participant/1 returns a event_participant changeset" do
      event_participant = event_participant_fixture()
      assert %Ecto.Changeset{} = Events.change_event_participant(event_participant)
    end
  end
end
