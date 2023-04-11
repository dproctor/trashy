defmodule Trashy.Promotions do
  @moduledoc """
  The Promotions context.
  """

  import Ecto.Query, warn: false
  alias Trashy.Repo

  alias Trashy.Promotions.Promotion

  @doc """
  Returns the list of promotions.

  ## Examples

      iex> list_promotions()
      [%Promotion{}, ...]

  """
  def list_promotions do
    Repo.all(Promotion)
  end

  @doc """
  Gets a single promotion.

  Raises `Ecto.NoResultsError` if the Promotion does not exist.

  ## Examples

      iex> get_promotion!(123)
      %Promotion{}

      iex> get_promotion!(456)
      ** (Ecto.NoResultsError)

  """
  def get_promotion!(id), do: Repo.get!(Promotion, id)

  @doc """
  Creates a promotion.

  ## Examples

      iex> create_promotion(%{field: value})
      {:ok, %Promotion{}}

      iex> create_promotion(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_promotion(attrs \\ %{}) do
    %Promotion{}
    |> Promotion.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a promotion.

  ## Examples

      iex> update_promotion(promotion, %{field: new_value})
      {:ok, %Promotion{}}

      iex> update_promotion(promotion, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_promotion(%Promotion{} = promotion, attrs) do
    promotion
    |> Promotion.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a promotion.

  ## Examples

      iex> delete_promotion(promotion)
      {:ok, %Promotion{}}

      iex> delete_promotion(promotion)
      {:error, %Ecto.Changeset{}}

  """
  def delete_promotion(%Promotion{} = promotion) do
    Repo.delete(promotion)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking promotion changes.

  ## Examples

      iex> change_promotion(promotion)
      %Ecto.Changeset{data: %Promotion{}}

  """
  def change_promotion(%Promotion{} = promotion, attrs \\ %{}) do
    Promotion.changeset(promotion, attrs)
  end
end
