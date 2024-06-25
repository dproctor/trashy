require Timex
Mix.Task.run("app.start")

alias Trashy.Repo
alias Trashy.Events

defmodule DataBackfill do
  @columns [
    "Date",
    "Cleanup Captain",
    "Expected attendance",
    "Actual Attendance",
    "Trash bags",
    "Cleanup"
  ]

  @cleanups %{
    "Bayview" => 11,
    "Bayview (All Good Pizza)" => 3,
    "Fillmore" => 9,
    "Hayes Valley" => 4,
    "Lower Nob Hill" => 6,
    "Lower Polk" => 5,
    "Mission North" => 2,
    "Mission South" => 1,
    "Ocean Beach" => 7,
    "West SOMA" => 8,
    "Ingleside" => 10
  }

  def handle_record(do_inserts, date, nil, participant_count, bag_count),
    do: {:error, "Bad cleanup id #{nil}"}

  def handle_record(do_inserts, {:error, msg}, cleanup_id, participant_count, bag_count),
    do: {:error, "Missing date #{msg}"}

  def handle_record(do_inserts, date, cleanup_id, :error, bag_count),
    do: {:error, "Bad participant_count"}

  def handle_record(do_inserts, date, cleanup_id, participant_count, :error),
    do: handle_record(do_inserts, date, cleanup_id, participant_count, {nil, ""})

  def handle_record(do_inserts, {:ok, date}, cleanup_id, {participant_count, _}, {bag_count, _}) do
    case Events.get_matching_events(cleanup_id, date) do
      [] ->
        case do_inserts do
          "true" ->
            {:ok, event} =
              Events.create_event(%{
                cleanup_id: cleanup_id,
                time: date,
                override_participant_count: participant_count,
                override_bag_count: bag_count
              })

            {:ok, event}

          _ ->
            {:error,
             "Ignoring event, do_inserts [#{do_inserts} #{date}, #{cleanup_id}, #{participant_count}, #{bag_count}]"}
        end

      _ ->
        {:error,
         "Ignoring event matching event [#{date}, #{cleanup_id}, #{participant_count}, #{bag_count}]"}
    end
  end

  def run(args) do
    case args do
      [filename, do_inserts | _] ->
        File.stream!(filename)
        |> CSV.decode()
        |> Enum.each(fn {:ok, record} ->
          case handle_record(
                 do_inserts,
                 record |> Enum.at(0) |> Timex.parse("{M}/{D}/{YYYY}"),
                 @cleanups[record |> Enum.at(5)],
                 record |> Enum.at(3) |> Integer.parse(),
                 record |> Enum.at(4) |> Integer.parse()
               ) do
            {:ok, event} ->
              IO.puts(
                "SUCCESS: [#{event.cleanup_id}, #{event.time}, #{event.override_participant_count}, #{event.override_bag_count}]"
              )

            {:error, msg} ->
              IO.puts("WARNING: #{msg}")
          end
        end)

        IO.puts("Data backfill complete!")

      _ ->
        IO.puts("Usage: mix run scripts/backfill_data.exs <filename> <do_inserts>")
    end

    # Fetch all records that need backfilling
  end
end

DataBackfill.run(System.argv())
