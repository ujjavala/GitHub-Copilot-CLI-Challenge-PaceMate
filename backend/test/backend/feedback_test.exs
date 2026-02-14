defmodule Backend.FeedbackTest do
  use ExUnit.Case
  doctest Backend.Feedback

  describe "random_feedback/0" do
    test "returns a string" do
      feedback = Backend.Feedback.random_feedback()
      assert is_binary(feedback)
    end

    test "returns non-empty string" do
      feedback = Backend.Feedback.random_feedback()
      assert String.length(feedback) > 0
    end

    test "returns one of the predefined messages" do
      valid_messages = [
        "Nice pacing. Keep it gentle.",
        "Try a soft start next time.",
        "Good breath before speaking.",
        "You're doing great. Take your time.",
        "Smooth delivery. Well done.",
        "Remember to breathe between phrases.",
        "Great effort! You're making progress."
      ]

      feedback = Backend.Feedback.random_feedback()
      assert Enum.member?(valid_messages, feedback)
    end

    test "generates different feedback on multiple calls" do
      feedbacks = for _ <- 1..100, do: Backend.Feedback.random_feedback()
      unique_feedbacks = feedbacks |> Enum.uniq() |> Enum.count()
      assert unique_feedbacks > 1
    end
  end
end
