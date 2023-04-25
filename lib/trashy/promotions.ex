defmodule Trashy.Promotions do
  @moduledoc """
  The Promotions context.
  """

  import Ecto.Query, warn: false
  alias Trashy.Repo

  alias Trashy.Promotions.Promotion
  alias Trashy.Promotions.EventParticipantPromotion

  @doc """
  Returns the list of promotions.

  ## Examples

      iex> list_promotions()
      [%Promotion{}, ...]

  """
  def list_promotions do
    Repo.all(Promotion)
    |> Repo.preload(:cleanup)
  end

  @doc """
  Returns the list of promotions for the provided cleanup.

  ## Examples

      iex> list_promotions_for_cleanup(promotion)
      [%Promotion{}, ...]

  """
  def list_promotions_for_cleanup(cleanup) do
    Repo.all(
      from(promotion in Promotion,
        where: promotion.cleanup_id == ^cleanup.id,
        distinct: true
      )
    )
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
  def get_promotion!(id),
    do:
      Repo.get!(Promotion, id)
      |> Repo.preload(:cleanup)

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

  alias Trashy.Promotions.EventParticipantPromotion

  @doc """
  Returns the list of event_participant_promotions.

  ## Examples

      iex> list_event_participant_promotions()
      [%EventParticipantPromotion{}, ...]

  """
  def list_event_participant_promotions do
    Repo.all(EventParticipantPromotion)
  end

  @doc """
  Returns the list of event_participant_promotions for the provided participant.

  ## Examples

      iex> list_event_participant_promotions(participant_id)
      [%EventParticipantPromotion{}, ...]

  """
  def list_event_participant_promotions(participant_id) do
    Repo.all(
      from(promotion in EventParticipantPromotion,
        where: promotion.event_participant_id == ^participant_id,
        distinct: true,
        order_by: [desc: promotion.id],
        preload: [:promotion]
      )
    )
  end

  @doc """
  Gets a single event_participant_promotion.

  Raises `Ecto.NoResultsError` if the Event participant promotion does not exist.

  ## Examples

      iex> get_event_participant_promotion!(123)
      %EventParticipantPromotion{}

      iex> get_event_participant_promotion!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event_participant_promotion!(id), do: Repo.get!(EventParticipantPromotion, id)

  @doc """
  Creates a event_participant_promotion.

  ## Examples

      iex> create_event_participant_promotion(%{field: value})
      {:ok, %EventParticipantPromotion{}}

      iex> create_event_participant_promotion(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event_participant_promotion(attrs \\ %{}) do
    %EventParticipantPromotion{}
    |> EventParticipantPromotion.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates all event_participant_promotions for the coresponding event_participant.

  ## Examples

      iex> create_event_participant_promotions(event_participant_id)
      :ok

  """
  def create_event_participant_promotions(event_participant_id) do
    participant = Trashy.Events.get_event_participant!(event_participant_id)
    event = Trashy.Events.get_event!(participant.event_id)
    cleanup = Trashy.Cleanups.get_cleanup_with_preloads(event.cleanup_id)

    cleanup.promotions
    |> Enum.map(fn promo ->
      %EventParticipantPromotion{}
      |> EventParticipantPromotion.changeset(%{
        event_participant_id: event_participant_id,
        promotion_id: promo.id
      })
    end)
    |> IO.inspect()
    |> Enum.each(&Repo.insert/1)

    :ok
  end

  @doc """
  Updates a event_participant_promotion.

  ## Examples

      iex> update_event_participant_promotion(event_participant_promotion, %{field: new_value})
      {:ok, %EventParticipantPromotion{}}

      iex> update_event_participant_promotion(event_participant_promotion, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event_participant_promotion(
        %EventParticipantPromotion{} = event_participant_promotion,
        attrs
      ) do
    event_participant_promotion
    |> EventParticipantPromotion.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a event_participant_promotion.

  ## Examples

      iex> delete_event_participant_promotion(event_participant_promotion)
      {:ok, %EventParticipantPromotion{}}

      iex> delete_event_participant_promotion(event_participant_promotion)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event_participant_promotion(
        %EventParticipantPromotion{} = event_participant_promotion
      ) do
    Repo.delete(event_participant_promotion)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event_participant_promotion changes.

  ## Examples

      iex> change_event_participant_promotion(event_participant_promotion)
      %Ecto.Changeset{data: %EventParticipantPromotion{}}

  """
  def change_event_participant_promotion(
        %EventParticipantPromotion{} = event_participant_promotion,
        attrs \\ %{}
      ) do
    EventParticipantPromotion.changeset(event_participant_promotion, attrs)
  end
end
