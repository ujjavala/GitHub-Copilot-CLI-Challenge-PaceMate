defmodule Backend.Sessions do
  @moduledoc """
  The Sessions context for managing practice sessions.
  """

  import Ecto.Query, warn: false
  alias Backend.Repo
  alias Backend.Sessions.Session

  @doc """
  Creates a new practice session.
  """
  def create_session(attrs \\ %{}) do
    %Session{}
    |> Session.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns all sessions ordered by most recent first.
  """
  def list_sessions(limit \\ 100) do
    Session
    |> order_by(desc: :practiced_at)
    |> limit(^limit)
    |> Repo.all()
  end

  @doc """
  Returns sessions from the last N days.
  """
  def list_recent_sessions(days \\ 30) do
    cutoff = DateTime.utc_now() |> DateTime.add(-days * 24 * 60 * 60, :second)

    Session
    |> where([s], s.practiced_at >= ^cutoff)
    |> order_by(desc: :practiced_at)
    |> Repo.all()
  end

  @doc """
  Returns total count of all practice sessions.
  """
  def count_sessions do
    Repo.aggregate(Session, :count, :id)
  end

  @doc """
  Returns total words spoken across all sessions.
  """
  def total_words do
    Repo.aggregate(Session, :sum, :word_count) || 0
  end

  @doc """
  Returns average WPM across all sessions.
  """
  def average_wpm do
    case Repo.aggregate(Session, :avg, :wpm) do
      nil -> 0
      avg -> Float.round(avg, 1)
    end
  end

  @doc """
  Returns the current practice streak (consecutive days).
  """
  def practice_streak do
    sessions =
      Session
      |> select([s], s.practiced_at)
      |> order_by(desc: :practiced_at)
      |> Repo.all()

    calculate_streak(sessions)
  end

  defp calculate_streak([]), do: 0

  defp calculate_streak(sessions) do
    sessions
    |> Enum.map(&DateTime.to_date/1)
    |> Enum.uniq()
    |> Enum.reduce_while({0, Date.utc_today()}, fn date, {streak, expected_date} ->
      cond do
        Date.compare(date, expected_date) == :eq ->
          {:cont, {streak + 1, Date.add(expected_date, -1)}}

        Date.compare(date, Date.add(expected_date, -1)) == :eq ->
          {:cont, {streak + 1, Date.add(expected_date, -1)}}

        true ->
          {:halt, {streak, expected_date}}
      end
    end)
    |> elem(0)
  end

  @doc """
  Returns WPM data for charting (date and avg WPM).
  """
  def wpm_over_time(days \\ 30) do
    cutoff = DateTime.utc_now() |> DateTime.add(-days * 24 * 60 * 60, :second)

    Session
    |> where([s], s.practiced_at >= ^cutoff)
    |> select([s], %{
      date: fragment("DATE(?)", s.practiced_at),
      avg_wpm: avg(s.wpm)
    })
    |> group_by([s], fragment("DATE(?)", s.practiced_at))
    |> order_by([s], fragment("DATE(?)", s.practiced_at))
    |> Repo.all()
  end

  @doc """
  Returns practice frequency data for heatmap (date and count).
  """
  def practice_frequency(days \\ 90) do
    cutoff = DateTime.utc_now() |> DateTime.add(-days * 24 * 60 * 60, :second)

    Session
    |> where([s], s.practiced_at >= ^cutoff)
    |> select([s], %{
      date: fragment("DATE(?)", s.practiced_at),
      count: count(s.id)
    })
    |> group_by([s], fragment("DATE(?)", s.practiced_at))
    |> order_by([s], fragment("DATE(?)", s.practiced_at))
    |> Repo.all()
  end

  @doc """
  Returns the most recent session.
  """
  def get_latest_session do
    Session
    |> order_by(desc: :practiced_at)
    |> limit(1)
    |> Repo.one()
  end

  @doc """
  Get session history for the last N days (for timeline charts).
  Returns raw session data ordered by practiced_at.
  """
  def get_session_history(days) do
    cutoff_date = DateTime.utc_now() |> DateTime.add(-(days * 24 * 60 * 60), :second)

    from(s in Session,
      where: s.practiced_at >= ^cutoff_date,
      order_by: [asc: s.practiced_at]
    )
    |> Repo.all()
  end
end
