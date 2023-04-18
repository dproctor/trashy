defmodule Trashy.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias Trashy.Repo

  alias Trashy.Events.Event

  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events()
      [%Event{}, ...]

  """
  def list_events do
    Repo.all(Event)
    |> Repo.preload(:cleanup)
  end

  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events_for_cleanup(cleanup)
      [%Event{}, ...]

  """
  def list_events_for_cleanup(cleanup) do
    Repo.all(
      from event in Event,
        where: event.cleanup_id == ^cleanup.id,
        distinct: true
    )
  end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

      iex> get_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(id), do: Repo.get!(Event, id)

  @doc """
  Creates a event.

  ## Examples

      iex> create_event(%{field: value})
      {:ok, %Event{}}

      iex> create_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a event.

  ## Examples

      iex> update_event(event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

      iex> change_event(event)
      %Ecto.Changeset{data: %Event{}}

  """
  def change_event(%Event{} = event, attrs \\ %{}) do
    Event.changeset(event, attrs)
  end

  alias Trashy.Events.EventParticipant

  @doc """
  Returns the list of event_participants.

  ## Examples

      iex> list_event_participants()
      [%EventParticipant{}, ...]

  """
  def list_event_participants do
    Repo.all(EventParticipant)
  end

  @doc """
  Returns the list of event_participants for a cleanup.

  ## Examples

      iex> list_event_participants_for_event(event)
      [%EventParticipant{}, ...]

  """
  def list_event_participants_for_event(event) do
    Repo.all(
      from participant in EventParticipant,
        where: participant.event_id == ^event.id,
        distinct: true
    )
  end

  @doc """
  Gets a single event_participant.

  Raises `Ecto.NoResultsError` if the Event participant does not exist.

  ## Examples

      iex> get_event_participant!(123)
      %EventParticipant{}

      iex> get_event_participant!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event_participant!(id), do: Repo.get!(EventParticipant, id)

  @doc """
  Creates a event_participant, along with the corresponding event_participant_promotions.

  ## Examples

      iex> create_event_participant(%{field: value})
      {:ok, %EventParticipant{}}

      iex> create_event_participant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event_participant(attrs \\ %{}) do
    {:ok, event_participant} =
      %EventParticipant{}
      |> EventParticipant.changeset(attrs)
      |> Repo.insert()

    Trashy.Promotions.create_event_participant_promotions(event_participant.id)

    {:ok, event_participant}
  end

  @doc """
  Updates a event_participant.

  ## Examples

      iex> update_event_participant(event_participant, %{field: new_value})
      {:ok, %EventParticipant{}}

      iex> update_event_participant(event_participant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event_participant(%EventParticipant{} = event_participant, attrs) do
    event_participant
    |> EventParticipant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a event_participant.

  ## Examples

      iex> delete_event_participant(event_participant)
      {:ok, %EventParticipant{}}

      iex> delete_event_participant(event_participant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event_participant(%EventParticipant{} = event_participant) do
    Repo.delete(event_participant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event_participant changes.

  ## Examples

      iex> change_event_participant(event_participant)
      %Ecto.Changeset{data: %EventParticipant{}}

  """
  def change_event_participant(%EventParticipant{} = event_participant, attrs \\ %{}) do
    EventParticipant.changeset(event_participant, attrs)
  end
end
