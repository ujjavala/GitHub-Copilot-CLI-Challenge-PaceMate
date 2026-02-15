defmodule BackendWeb.AnalyticsController do
  use BackendWeb, :controller

  alias Backend.Sessions

  def summary(conn, _params) do
    total_sessions = Sessions.count_sessions()
    total_words = Sessions.total_words()
    average_wpm = Sessions.average_wpm()
    current_streak = Sessions.practice_streak()

    data = %{
      total_sessions: total_sessions,
      total_words: total_words,
      average_wpm: average_wpm,
      current_streak: current_streak
    }

    render(conn, :summary, data: data)
  end
end
