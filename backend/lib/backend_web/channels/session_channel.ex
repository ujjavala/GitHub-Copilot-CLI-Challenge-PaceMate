defmodule BackendWeb.SessionChannel do
  use BackendWeb, :channel

  @impl true
  def join("session:user_session", _payload, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_in("finished_speaking", %{"speech" => speech_text}, socket) when is_binary(speech_text) do
    case Backend.AI.SpeechAnalysis.analyze_speech(speech_text) do
      {:ok, feedback} ->
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

  def handle_in("finished_speaking", _payload, socket) do
    # Fallback for empty payload
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
end
