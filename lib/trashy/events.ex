defmodule Trashy.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias Trashy.Repo

  alias Trashy.Events.Event
  alias Trashy.Events.EventParticipant
  alias Trashy.Cleanups.Cleanup

  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events()
      [%Event{}, ...]

  """
  def list_events do
    Repo.all(
      from event in Event,
        order_by: [desc: event.time]
    )
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
        distinct: true,
        order_by: [desc: event.time]
    )
  end

  @doc """
  Returns the list of events matching the query.

  ## Examples

      iex> get_matching_events(cleanup)
      [%Event{}, ...]

  """
  def get_matching_events(cleanup_id, time, time_offset_hours \\ 48) do
    start = Timex.shift(time, hours: -1 * time_offset_hours)
    finish = Timex.shift(time, hours: time_offset_hours)

    Repo.all(
      from event in Event,
        where: event.cleanup_id == ^cleanup_id and event.time >= ^start and event.time <= ^finish,
        distinct: true,
        order_by: [desc: event.time]
    )
  end

  @doc """
  Returns the list of events which a participant has attended, as a list of datetimes and cleanup_ids.

  ## Examples

      iex> list_events_for_participant(cleanup)
      [%Event{}, ...]

  """

  def get_total_participant_cleanup_count(participant) do
    query =
      from event_participant in EventParticipant,
        where:
          fragment("lower(?)", event_participant.email) == ^String.downcase(participant.email) and
            fragment("lower(?)", event_participant.first_name) ==
              ^String.downcase(participant.first_name),
        join: event in Event,
        on: event_participant.event_id == event.id,
        select: count(event_participant.id)

    Repo.one!(query)
  end

  def get_local_participant_cleanup_count(participant, event) do
    query =
      from event_participant in EventParticipant,
        where:
          fragment("lower(?)", event_participant.email) == ^String.downcase(participant.email) and
            fragment("lower(?)", event_participant.first_name) ==
              ^String.downcase(participant.first_name),
        join: event in Event,
        on: event_participant.event_id == event.id,
        where: event.cleanup_id == ^event.cleanup_id,
        select: count(event_participant.id)

    Repo.one!(query)
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
  Creates new recurring events for appropriately configured cleanups.

  ## Examples

      iex> create_new_recurring_events(%{field: value})
      [%Event{}, ...]

  """
  def create_new_recurring_events(weeks_ahead) do
    Repo.all(
      from cleanup in Cleanup,
        where: cleanup.enable_recurring_events and not is_nil(cleanup.regular_datetime)
    )
    |> Enum.flat_map(fn cleanup ->
      # get datetime of next instance

      next_event_time =
        Timex.today()
        |> Timex.shift(days: 7)
        |> Timex.beginning_of_week()
        |> Timex.shift(days: Date.day_of_week(cleanup.regular_datetime) - 1)
        |> NaiveDateTime.new!(NaiveDateTime.to_time(cleanup.regular_datetime))

      0..(weeks_ahead - 1)
      |> Enum.map(fn n ->
        case get_matching_events(cleanup.id, next_event_time, 24) do
          [] ->
            create_event(%{
              cleanup_id: cleanup.id,
              time: NaiveDateTime.add(next_event_time, 7 * n, :day)
            })

          _ ->
            IO.puts(
              "create_new_recurring_events: Not creating recurring event #{cleanup.id} #{next_event_time}, event already exists"
            )

            nil
        end
      end)
    end)
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
