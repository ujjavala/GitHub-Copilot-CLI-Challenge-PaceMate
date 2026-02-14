defmodule Backend.Feedback do
  @feedback_messages [
    "Nice pacing. Keep it gentle.",
    "Try a soft start next time.",
    "Good breath before speaking.",
    "You're doing great. Take your time.",
    "Smooth delivery. Well done.",
    "Remember to breathe between phrases.",
    "Great effort! You're making progress."
  ]

  def random_feedback do
    Enum.random(@feedback_messages)
  end
end
