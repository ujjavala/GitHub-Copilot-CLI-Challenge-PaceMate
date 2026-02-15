defmodule Backend.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :speech_text, :text, null: false
      add :word_count, :integer, null: false
      add :sentence_count, :integer
      add :wpm, :integer, null: false
      add :avg_sentence_length, :float
      add :feedback_encouragement, :text
      add :feedback_pacing, :text
      add :feedback_tips, :text
      add :practiced_at, :utc_datetime, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:sessions, [:practiced_at])
    create index(:sessions, [:wpm])
  end
end
