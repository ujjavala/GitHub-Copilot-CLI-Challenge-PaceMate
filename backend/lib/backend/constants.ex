defmodule Backend.Constants do
  @moduledoc """
  Application-wide constants and static text.
  """

  # Dashboard constants
  def dashboard_title, do: "Your Practice Journey"
  def dashboard_subtitle, do: "Track your mindful speaking progress"

  # Chart titles
  def chart_wpm_title, do: "Speaking Pace Over Time"
  def chart_frequency_title, do: "Practice Frequency"
  def chart_recent_sessions_title, do: "Recent Sessions"

  # Stats labels
  def stat_total_sessions, do: "Total Sessions"
  def stat_total_words, do: "Words Spoken"
  def stat_average_wpm, do: "Average WPM"
  def stat_practice_streak, do: "Day Streak"

  # Messages
  def no_sessions_message, do: "No practice sessions yet. Start your first session!"
  def loading_message, do: "Loading your practice data..."
  def error_message, do: "Unable to load dashboard. Please try again."

  # Time periods
  def period_last_30_days, do: "Last 30 Days"
  def period_last_90_days, do: "Last 90 Days"
  def period_all_time, do: "All Time"

  # Encouragement messages for milestones
  def milestone_first_session, do: "🎉 First session complete!"
  def milestone_10_sessions, do: "🌟 10 sessions completed!"
  def milestone_50_sessions, do: "🔥 50 sessions! You're on fire!"
  def milestone_100_sessions, do: "💎 100 sessions! Incredible dedication!"
  def milestone_7_day_streak, do: "⚡ 7-day streak! Consistency is key!"
  def milestone_30_day_streak, do: "🏆 30-day streak! Absolutely amazing!"

  # Chart colors (for VegaLite)
  def color_primary, do: "#06b6d4"
  def color_secondary, do: "#0ea5e9"
  def color_success, do: "#10b981"
  def color_warning, do: "#f59e0b"
  def color_gradient_start, do: "#38bdf8"
  def color_gradient_end, do: "#06b6d4"

  # Animation durations (milliseconds)
  def animation_fade_in, do: 300
  def animation_slide_in, do: 400
  def animation_chart_render, do: 500
end
