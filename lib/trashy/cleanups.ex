defmodule Trashy.Cleanups do
  @moduledoc """
  The Cleanups context.
  """

  import Ecto.Query, warn: false
  alias Trashy.Repo

  alias Trashy.Cleanups.Cleanup

  @doc """
  Returns the list of cleanups.

  ## Examples

      iex> list_cleanups()
      [%Cleanup{}, ...]

  """
  def list_cleanups do
    Repo.all(Cleanup)
  end

  @doc """
  Returns the list of cleanups for which the provided user is an organizer.

  ## Examples

      iex> list_cleanups_for_user(user)
      [%Cleanup{}, ...]

  """
  def list_cleanups_for_user(user) do
    Repo.all(
      from cleanup in Cleanup,
        join: co in Trashy.Cleanups.CleanupOrganizer,
        on: cleanup.id == co.cleanup_id,
        join: o in Trashy.Accounts.User,
        on: co.organizer_id == o.id,
        where: o.id == ^user.id,
        distinct: true,
        preload: [:promotions],
        select: cleanup
    )
  end

  @doc """
  Gets a single cleanup.

  Raises `Ecto.NoResultsError` if the Cleanup does not exist.

  ## Examples

      iex> get_cleanup!(123)
      %Cleanup{}

      iex> get_cleanup!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cleanup!(id), do: Repo.get!(Cleanup, id)

  @doc """
  Gets a single cleanup with preloads.

  Raises `Ecto.NoResultsError` if the Cleanup does not exist.

  ## Examples

      iex> get_cleanup_with_preloads(123)
      %Cleanup{}

  """
  def get_cleanup_with_preloads(id) do
    Repo.one(
      from cleanup in Cleanup,
        where: cleanup.id == ^id,
        preload: [:promotions]
    )
  end

  @doc """
  Creates a cleanup.

  ## Examples

      iex> create_cleanup(%{field: value})
      {:ok, %Cleanup{}}

      iex> create_cleanup(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cleanup(attrs \\ %{}) do
    %Cleanup{}
    |> Cleanup.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cleanup.

  ## Examples

      iex> update_cleanup(cleanup, %{field: new_value})
      {:ok, %Cleanup{}}

      iex> update_cleanup(cleanup, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cleanup(%Cleanup{} = cleanup, attrs) do
    cleanup
    |> Cleanup.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a cleanup.

  ## Examples

      iex> delete_cleanup(cleanup)
      {:ok, %Cleanup{}}

      iex> delete_cleanup(cleanup)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cleanup(%Cleanup{} = cleanup) do
    Repo.delete(cleanup)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cleanup changes.

  ## Examples

      iex> change_cleanup(cleanup)
      %Ecto.Changeset{data: %Cleanup{}}

  """
  def change_cleanup(%Cleanup{} = cleanup, attrs \\ %{}) do
    Cleanup.changeset(cleanup, attrs)
  end

  alias Trashy.Cleanups.CleanupOrganizer

  @doc """
  Returns the list of cleanup_organizers.

  ## Examples

      iex> list_cleanup_organizers()
      [%CleanupOrganizer{}, ...]

  """
  def list_cleanup_organizers do
    Repo.all(CleanupOrganizer)
  end

  @doc """
  Gets a single cleanup_organizer.

  Raises `Ecto.NoResultsError` if the Cleanup organizer does not exist.

  ## Examples

      iex> get_cleanup_organizer!(123)
      %CleanupOrganizer{}

      iex> get_cleanup_organizer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cleanup_organizer!(id), do: Repo.get!(CleanupOrganizer, id)

  @doc """
  Creates a cleanup_organizer.

  ## Examples

      iex> create_cleanup_organizer(%{field: value})
      {:ok, %CleanupOrganizer{}}

      iex> create_cleanup_organizer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cleanup_organizer(attrs \\ %{}) do
    %CleanupOrganizer{}
    |> CleanupOrganizer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cleanup_organizer.

  ## Examples

      iex> update_cleanup_organizer(cleanup_organizer, %{field: new_value})
      {:ok, %CleanupOrganizer{}}

      iex> update_cleanup_organizer(cleanup_organizer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cleanup_organizer(%CleanupOrganizer{} = cleanup_organizer, attrs) do
    cleanup_organizer
    |> CleanupOrganizer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a cleanup_organizer.

  ## Examples

      iex> delete_cleanup_organizer(cleanup_organizer)
      {:ok, %CleanupOrganizer{}}

      iex> delete_cleanup_organizer(cleanup_organizer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cleanup_organizer(%CleanupOrganizer{} = cleanup_organizer) do
    Repo.delete(cleanup_organizer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cleanup_organizer changes.

  ## Examples

      iex> change_cleanup_organizer(cleanup_organizer)
      %Ecto.Changeset{data: %CleanupOrganizer{}}

  """
  def change_cleanup_organizer(%CleanupOrganizer{} = cleanup_organizer, attrs \\ %{}) do
    CleanupOrganizer.changeset(cleanup_organizer, attrs)
  end
end
