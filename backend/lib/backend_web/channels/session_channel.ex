defmodule BackendWeb.SessionChannel do
  use BackendWeb, :channel

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
end
