defmodule BackendWeb.SessionController do
  use BackendWeb, :controller
  alias Backend.Sessions

  @doc """
  Get session history aggregated by date for the last 30 days
  """
  def history(conn, _params) do
    days = 30
    history = Sessions.get_session_history(days)

    # Aggregate sessions by date
    aggregated =
      history
      |> Enum.group_by(fn session ->
        session.practiced_at
        |> DateTime.to_date()
        |> Date.to_string()
      end)
      |> Enum.map(fn {date, sessions} ->
        %{
          date: date,
          sessions: length(sessions),
          words: Enum.sum(Enum.map(sessions, & &1.word_count)),
          avgWpm: calculate_average(sessions, :wpm)
        }
      end)
      |> Enum.sort_by(& &1.date)

    json(conn, aggregated)
  end

  # Calculate average for a given field
  defp calculate_average(sessions, field) do
    if Enum.empty?(sessions) do
      0.0
    else
      sum = Enum.reduce(sessions, 0, fn session, acc -> acc + Map.get(session, field, 0) end)
      sum / length(sessions)
    end
  end
end
