defmodule Backend.Sessions.Session do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sessions" do
    field :speech_text, :string
    field :word_count, :integer
    field :sentence_count, :integer
    field :wpm, :integer
    field :avg_sentence_length, :float
    field :feedback_encouragement, :string
    field :feedback_pacing, :string
    field :feedback_tips, {:array, :string}
    field :practiced_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [
      :speech_text,
      :word_count,
      :sentence_count,
      :wpm,
      :avg_sentence_length,
      :feedback_encouragement,
      :feedback_pacing,
      :feedback_tips,
      :practiced_at
    ])
    |> validate_required([
      :speech_text,
      :word_count,
      :wpm,
      :practiced_at
    ])
    |> validate_number(:word_count, greater_than_or_equal_to: 0)
    |> validate_number(:wpm, greater_than_or_equal_to: 0)
  end
end
