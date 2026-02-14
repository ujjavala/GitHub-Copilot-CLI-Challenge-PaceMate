defmodule Backend.AI.SpeechAnalysis do
  @moduledoc """
  Analyzes speech patterns and provides AI-powered pacing and stutter tips.
  Uses Ollama for local LLM-based feedback generation.
  """

  @doc """
  Analyze speech and generate personalized feedback.

  Accepts speech text and returns structured feedback including:
  - Pacing analysis (words per minute)
  - Stutter tips
  - Encouragement
  - Specific recommendations
  """
  @spec analyze_speech(String.t()) :: {:ok, map()} | {:error, String.t()}
  def analyze_speech(speech_text) when is_binary(speech_text) and byte_size(speech_text) > 0 do
    case parse_speech_metrics(speech_text) do
      {:ok, metrics} ->
        generate_ai_feedback(speech_text, metrics)

      {:error, reason} ->
        {:error, reason}
    end
  end

  def analyze_speech(_), do: {:error, "Invalid speech input"}

  @doc """
  Calculate pacing metrics from speech text.
  """
  @spec parse_speech_metrics(String.t()) :: {:ok, map()} | {:error, String.t()}
  defp parse_speech_metrics(text) do
    words = String.split(text) |> length()
    sentences = count_sentences(text)
    avg_sentence_length = if sentences > 0, do: words / sentences, else: 0

    {:ok,
     %{
       words: words,
       sentences: sentences,
       avg_sentence_length: avg_sentence_length,
       estimated_wpm: estimate_wpm(words),
       has_pauses: String.contains?(text, "...")
     }}
  end

  @doc """
  Count sentences in text (simple heuristic).
  """
  @spec count_sentences(String.t()) :: non_neg_integer()
  defp count_sentences(text) do
    text
    |> String.split(~r/[.!?]+/)
    |> Enum.count(fn s -> String.trim(s) != "" end)
  end

  @doc """
  Estimate words per minute (assuming 120 WPM for calm speech).
  """
  @spec estimate_wpm(non_neg_integer()) :: float()
  defp estimate_wpm(words) do
    # Typical speaking rate: 120-150 WPM for calm speech
    # We assume ~30 seconds of speaking for POC
    (words / 30) * 60
  end

  @doc """
  Generate AI-powered feedback using Ollama.
  Falls back to rule-based feedback if Ollama unavailable.
  """
  @spec generate_ai_feedback(String.t(), map()) :: {:ok, map()} | {:error, String.t()}
  defp generate_ai_feedback(speech_text, metrics) do
    case query_ollama(speech_text, metrics) do
      {:ok, ai_feedback} ->
        {:ok,
         %{
           "pacing" => format_pacing_feedback(metrics),
           "tips" => ai_feedback["tips"] || rule_based_tips(metrics),
           "encouragement" => ai_feedback["encouragement"],
           "metrics" => %{
             "words" => metrics.words,
             "sentences" => metrics.sentences,
             "avg_sentence_length" => Float.round(metrics.avg_sentence_length, 2),
             "estimated_wpm" => Float.round(metrics.estimated_wpm, 2)
           }
         }}

      {:error, _} ->
        # Fallback to rule-based feedback if AI unavailable
        {:ok,
         %{
           "pacing" => format_pacing_feedback(metrics),
           "tips" => rule_based_tips(metrics),
           "encouragement" => Backend.Feedback.random_feedback(),
           "metrics" => %{
             "words" => metrics.words,
             "sentences" => metrics.sentences,
             "avg_sentence_length" => Float.round(metrics.avg_sentence_length, 2),
             "estimated_wpm" => Float.round(metrics.estimated_wpm, 2)
           }
         }}
    end
  end

  @doc """
  Query Ollama for AI-generated feedback.
  """
  @spec query_ollama(String.t(), map()) :: {:ok, map()} | {:error, String.t()}
  defp query_ollama(speech_text, metrics) do
    ollama_host = System.get_env("OLLAMA_HOST") || "http://localhost:11434"

    prompt = """
    Analyze this speech for someone who has a speech stutter and provide brief, encouraging feedback.
    
    Speech: "#{speech_text}"
    
    Metrics:
    - Words: #{metrics.words}
    - Sentences: #{metrics.sentences}
    - Avg words per sentence: #{Float.round(metrics.avg_sentence_length, 2)}
    - Estimated WPM: #{Float.round(metrics.estimated_wpm, 2)}
    
    Provide feedback in this exact format:
    TIPS: [2-3 specific, actionable tips for pacing and clarity]
    ENCOURAGEMENT: [brief, warm encouragement]
    """

    case HTTPoison.post(
           "#{ollama_host}/api/generate",
           Jason.encode!(%{
             model: "llama2",
             prompt: prompt,
             stream: false
           }),
           [{"Content-Type", "application/json"}],
           []
         ) do
      {:ok, response} ->
        parse_ollama_response(response.body)

      {:error, _reason} ->
        {:error, "Ollama unavailable"}
    end
  rescue
    _ -> {:error, "Ollama connection failed"}
  end

  @doc """
  Parse Ollama API response.
  """
  @spec parse_ollama_response(String.t()) :: {:ok, map()} | {:error, String.t()}
  defp parse_ollama_response(body) do
    case Jason.decode(body) do
      {:ok, %{"response" => response}} ->
        extract_feedback_from_response(response)

      {:error, _} ->
        {:error, "Failed to parse Ollama response"}
    end
  rescue
    _ -> {:error, "Error processing Ollama response"}
  end

  @doc """
  Extract structured feedback from Ollama response.
  """
  @spec extract_feedback_from_response(String.t()) :: {:ok, map()} | {:error, String.t()}
  defp extract_feedback_from_response(response) do
    case Regex.scan(~r/TIPS:\s*(.*?)\n/s, response) do
      [[_, tips]] ->
        encouragement =
          case Regex.scan(~r/ENCOURAGEMENT:\s*(.*?)$/s, response) do
            [[_, enc]] -> String.trim(enc)
            _ -> "You're doing great!"
          end

        {:ok,
         %{
           "tips" => String.trim(tips),
           "encouragement" => encouragement
         }}

      _ ->
        {:error, "Could not parse Ollama response"}
    end
  end

  @doc """
  Format pacing feedback based on metrics.
  """
  @spec format_pacing_feedback(map()) :: String.t()
  defp format_pacing_feedback(%{estimated_wpm: wpm, avg_sentence_length: avg_len} = metrics) do
    pacing =
      cond do
        wpm < 80 -> "You're speaking quite slowly - consider picking up pace slightly."
        wpm > 160 -> "You're speaking quickly - try slowing down and adding more pauses."
        true -> "Your pacing is good - try to maintain this steady rhythm."
      end

    sentence_feedback =
      cond do
        avg_len > 15 -> " Your sentences are long - consider breaking them into shorter phrases."
        avg_len < 5 -> " Your sentences are short - this is great for clarity."
        true -> " Your sentence length is balanced."
      end

    pause_advice =
      if metrics.has_pauses,
        do: " Great job including pauses!",
        else: " Consider adding pauses between thoughts."

    pacing <> sentence_feedback <> pause_advice
  end

  @doc """
  Rule-based tips for when Ollama is unavailable.
  """
  @spec rule_based_tips(map()) :: String.t()
  defp rule_based_tips(%{estimated_wpm: wpm, sentences: sentences}) do
    tips = []

    tips =
      if wpm > 150,
        do: tips ++ ["Try speaking more slowly and deliberately"],
        else: tips

    tips =
      if wpm < 80,
        do: tips ++ ["You can speak with more confidence"],
        else: tips

    tips =
      if sentences < 2,
        do: tips ++ ["Break your response into multiple sentences"],
        else: tips

    tips =
      if Enum.empty?(tips),
        do: ["Maintain your current pace", "Your clarity is excellent"],
        else: tips

    tips |> Enum.join(". ") <> "."
  end
end
