defmodule BackendWeb.SessionChannel do
  use BackendWeb, :channel
  alias Backend.Sessions

  @impl true
  def join("session:user_session", _payload, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_in("finished_speaking", %{"speech" => speech_text}, socket) when is_binary(speech_text) do
    IO.puts("[Backend] Received speech text: '#{speech_text}'")
    IO.puts("[Backend] Speech text length: #{String.length(speech_text)}")

    case Backend.AI.SpeechAnalysis.analyze_speech(speech_text) do
      {:ok, feedback} ->
        # Store session in database
        store_session(speech_text, feedback)

        # Broadcast update to dashboard (if connected)
        Phoenix.PubSub.broadcast(
          Backend.PubSub,
          "dashboard:updates",
          {:new_session, feedback}
        )

        {:reply, {:ok, feedback}, socket}

      {:error, _reason} ->
        # Fallback to simple feedback if AI fails
        feedback = %{
          "encouragement" => Backend.Feedback.random_feedback(),
          "pacing" => "Keep practicing your pacing!",
          "tips" => "Take your time and speak clearly.",
          "metrics" => nil
        }

        {:reply, {:ok, feedback}, socket}
    end
  end

  def handle_in("finished_speaking", payload, socket) do
    # Fallback for empty payload
    IO.puts("[Backend] Received finished_speaking without valid speech text")
    IO.inspect(payload, label: "[Backend] Payload")

    feedback = %{
      "encouragement" => Backend.Feedback.random_feedback(),
      "pacing" => "Keep practicing your pacing!",
      "tips" => "Take your time and speak clearly.",
      "metrics" => nil
    }

    {:reply, {:ok, feedback}, socket}
  end

  @impl true
  def handle_in("restart_session", _payload, socket) do
    {:reply, :ok, socket}
  end

  # Private helper to store session data
  defp store_session(speech_text, feedback) do
    metrics = feedback["metrics"]

    attrs = %{
      speech_text: speech_text,
      word_count: get_in(metrics, ["words"]) || 0,
      sentence_count: get_in(metrics, ["sentences"]) || 0,
      wpm: get_in(metrics, ["wpm"]) || 0,
      avg_sentence_length: get_in(metrics, ["avg_sentence_length"]) || 0.0,
      feedback_encouragement: feedback["encouragement"],
      feedback_pacing: feedback["pacing"],
      feedback_tips: parse_tips(feedback["tips"]),
      practiced_at: DateTime.utc_now()
    }

    case Sessions.create_session(attrs) do
      {:ok, session} ->
        IO.puts("[Backend] Session stored successfully with ID: #{session.id}")

      {:error, changeset} ->
        IO.puts("[Backend] Failed to store session")
        IO.inspect(changeset, label: "[Backend] Changeset errors")
    end
  end

  defp parse_tips(nil), do: []
  defp parse_tips(tips) when is_binary(tips), do: String.split(tips, "\n", trim: true)
  defp parse_tips(tips) when is_list(tips), do: tips
  defp parse_tips(_), do: []
end
