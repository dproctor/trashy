defmodule Trashy.RegistrationsTest do
  use Trashy.DataCase

  alias Trashy.Registrations

  describe "registrations" do
    alias Trashy.Registrations.Registration

    import Trashy.RegistrationsFixtures

    @invalid_attrs %{email: nil, name: nil}

    test "list_registrations/0 returns all registrations" do
      registration = registration_fixture()
      assert Registrations.list_registrations() == [registration]
    end

    test "get_registration!/1 returns the registration with given id" do
      registration = registration_fixture()
      assert Registrations.get_registration!(registration.id) == registration
    end

    test "create_registration/1 with valid data creates a registration" do
      valid_attrs = %{email: "some email", name: "some name"}

      assert {:ok, %Registration{} = registration} = Registrations.create_registration(valid_attrs)
      assert registration.email == "some email"
      assert registration.name == "some name"
    end

    test "create_registration/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Registrations.create_registration(@invalid_attrs)
    end

    test "update_registration/2 with valid data updates the registration" do
      registration = registration_fixture()
      update_attrs = %{email: "some updated email", name: "some updated name"}

      assert {:ok, %Registration{} = registration} = Registrations.update_registration(registration, update_attrs)
      assert registration.email == "some updated email"
      assert registration.name == "some updated name"
    end

    test "update_registration/2 with invalid data returns error changeset" do
      registration = registration_fixture()
      assert {:error, %Ecto.Changeset{}} = Registrations.update_registration(registration, @invalid_attrs)
      assert registration == Registrations.get_registration!(registration.id)
    end

    test "delete_registration/1 deletes the registration" do
      registration = registration_fixture()
      assert {:ok, %Registration{}} = Registrations.delete_registration(registration)
      assert_raise Ecto.NoResultsError, fn -> Registrations.get_registration!(registration.id) end
    end

    test "change_registration/1 returns a registration changeset" do
      registration = registration_fixture()
      assert %Ecto.Changeset{} = Registrations.change_registration(registration)
    end
  end
end
