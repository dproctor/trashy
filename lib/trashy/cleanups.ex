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
end
