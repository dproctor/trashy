defmodule Trashy.CleanupsTest do
  use Trashy.DataCase

  alias Trashy.Cleanups

  describe "cleanups" do
    alias Trashy.Cleanups.Cleanup

    import Trashy.CleanupsFixtures

    @invalid_attrs %{location: nil}

    test "list_cleanups/0 returns all cleanups" do
      cleanup = cleanup_fixture()
      assert Cleanups.list_cleanups() == [cleanup]
    end

    test "get_cleanup!/1 returns the cleanup with given id" do
      cleanup = cleanup_fixture()
      assert Cleanups.get_cleanup!(cleanup.id) == cleanup
    end

    test "create_cleanup/1 with valid data creates a cleanup" do
      valid_attrs = %{location: "some location"}

      assert {:ok, %Cleanup{} = cleanup} = Cleanups.create_cleanup(valid_attrs)
      assert cleanup.location == "some location"
    end

    test "create_cleanup/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Cleanups.create_cleanup(@invalid_attrs)
    end

    test "update_cleanup/2 with valid data updates the cleanup" do
      cleanup = cleanup_fixture()
      update_attrs = %{location: "some updated location"}

      assert {:ok, %Cleanup{} = cleanup} = Cleanups.update_cleanup(cleanup, update_attrs)
      assert cleanup.location == "some updated location"
    end

    test "update_cleanup/2 with invalid data returns error changeset" do
      cleanup = cleanup_fixture()
      assert {:error, %Ecto.Changeset{}} = Cleanups.update_cleanup(cleanup, @invalid_attrs)
      assert cleanup == Cleanups.get_cleanup!(cleanup.id)
    end

    test "delete_cleanup/1 deletes the cleanup" do
      cleanup = cleanup_fixture()
      assert {:ok, %Cleanup{}} = Cleanups.delete_cleanup(cleanup)
      assert_raise Ecto.NoResultsError, fn -> Cleanups.get_cleanup!(cleanup.id) end
    end

    test "change_cleanup/1 returns a cleanup changeset" do
      cleanup = cleanup_fixture()
      assert %Ecto.Changeset{} = Cleanups.change_cleanup(cleanup)
    end
  end
end
