defmodule BackendWeb.AnalyticsJSON do
  @moduledoc """
  JSON rendering for analytics data
  """

  def summary(%{data: data}) do
    %{
      totalSessions: data.total_sessions,
      totalWords: data.total_words,
      averageWpm: data.average_wpm,
      currentStreak: data.current_streak
    }
  end
end
