*This is a submission for the [GitHub Copilot CLI Challenge](https://dev.to/challenges/github-2026-01-21)*

## What I Built

I went a little crazy 😎.

I built a stutter-accessibility app in one day. Why one day? I've been swamped, finally got breathing space this weekend, and thought: why not make something meaningful AND wild at the same time.

**PaceMate**: a calm, guided speaking experience for people who stutter. This is deeply personal—I've faced stuttering challenges myself, spent heaps on therapy, and realized not everyone can afford it. So I used my engineering skills to help the community.

**What it does:**
Start session → Breathing exercise → Read a prompt → Speak (Web Speech API transcription) → Get gentle AI feedback + pacing metrics 

## Key Features

**Core Flow:** 5-state session (Idle → Breathing → Prompt → Speaking → Feedback)

**Real-Time:** WebSocket via Phoenix Channels, <500ms latency, isolated Erlang processes

**AI Feedback:** Local Ollama + Phi3 (privacy-first) with rule-based fallback. Analyzes WPM, sentence structure, flow patterns, breath points

**UI/UX:** Clean design, dark mode, fully responsive, accessibility-first, animated breathing guide

**Metrics:** Duration, transcript, word count, pacing analysis, personalized recommendations

**Dev-Friendly:** Docker Compose setup, comprehensive docs, 33+ tests (>85% coverage)

## Why Elm & Elixir?

Because sometimes, the forgotten things are the coolest.

**Elm:** Zero runtime errors, type-safe messages, predictable state machine—perfect for accessibility-focused UI where crashes aren't an option.

**Elixir:** Fault-tolerant concurrency (isolated processes), real-time WebSockets, hot code reloading—perfect for managing multiple sessions without a messy backend.

Most people skip these languages because they "aren't popular." For this app? They're perfect. Right tool for the mission, not the trend.

## How AI Fits In

Local **Ollama + Phi3** for gentle feedback. Why local? Privacy (data never leaves device), zero API costs, no internet required.

**Sample feedback:** "Nice pacing. Keep it gentle." / "Try a soft start next time." / "You're doing great. Take your time."

**Fallback:** If Ollama isn't running, rule-based feedback kicks in—no broken experiences.

## Tech Stack

**Frontend:** Elm 0.19.1, WebSockets (Phoenix Channels), CSS Grid/Flexbox, Font Awesome 6
**Backend:** Elixir 1.19.5, Phoenix 1.8.3, HTTPoison (Ollama client)
**AI:** Ollama + Phi3 (local LLM)
**DevOps:** Docker + Compose, Alpine Linux, Fly.io (backend), Netlify (frontend), GitHub Actions (CI/CD)
**Testing:** ExUnit + Elm test, 33+ tests, >85% coverage

## Demo & Repository

🎥 [**Demo Video**](https://youtu.be/qEtrt2MXVQA)
🌐 [**Live Demo**](https://pace-mate.netlify.app/) (Fly.io free tier—falls back to rule-based feedback after expiry)
📦 [**GitHub Repo**](https://github.com/ujjavala/GitHub-Copilot-CLI-Challenge-PaceMate)

**Quick Start:**
```bash
git clone https://github.com/ujjavala/GitHub-Copilot-CLI-Challenge-PaceMate.git
cd github-challenge
docker-compose --profile ai up  # With AI (Phi3 downloads ~2GB first run)
# OR docker-compose up  # Without AI (rule-based feedback)
# Open http://localhost:3000
```

## My Experience with GitHub Copilot CLI

Copilot CLI was the game-changer that made this one-day sprint possible.

**What it handled:**
✅ Elm state machines & JSON decoders (tricky type-safe patterns)
✅ Phoenix Channels boilerplate & routing (idiomatic Elixir)
✅ Docker health checks & multi-stage builds (Alpine specifics)
✅ GitHub Actions CI/CD & Fly.io/Netlify deployment
✅ Test cases, error handling, CSS Grid, environment configs
✅ Documentation structure across 5+ markdown files
✅ Git workflow & deployment scripts

**The real win?** I stayed in flow. Copilot handled syntax/boilerplate while I focused on *why* this matters for users who stutter and *how* to make it supportive. Cross-project context awareness (Elm ↔ Elixir ↔ DevOps) meant zero doc-hopping.

### Code Examples That Saved Hours

**Elm State Machine** (no trial and error):
```elm
type SessionState = Idle | Breathing | ShowingPrompt | Speaking | ShowingFeedback FeedbackData
type Msg = StartSession | FinishBreathing | StartSpeaking | StopSpeaking | ReceiveFeedback String
```

**Phoenix Channel Handler** (idiomatic Elixir pattern matching):
```elixir
def handle_in("speech_complete", %{"transcript" => t, "duration" => d}, socket) do
  push(socket, "feedback", %{message: feedback.message, metrics: %{wpm: ...}})
  {:noreply, socket}
end
```

**Docker Health Check** (Alpine-aware, production-ready):
```dockerfile
HEALTHCHECK --interval=30s CMD wget --spider http://localhost:4000/api/health || exit 1
```

These weren't just syntax—Copilot understood each framework's idioms and saved me from doc-hopping.

### Not an Expert, Just Determined

**Truth:** I'm not an Elm expert or Elixir wizard. Last touched Elixir 8 years ago. Elm was new.

Normally, diving into two "forgotten" functional languages for a one-day project = serious jitters. But with Copilot CLI? **No jitters. Just flow.**

**I felt more like an architect than a coder.** I focused on *why* and *how* (why does this transition matter for users who stutter? how should feedback feel supportive?). Copilot handled *what* (exact Elm decoder syntax, idiomatic Elixir patterns, Docker flags).

**Role shift:** Product thinking mode, not syntax translation mode. No juggling docs/Stack Overflow tabs. Designing, deciding, directing—Copilot translated intent to implementation.

8 years ago without AI? Half the day reading docs, half debugging compiler errors. Instead: building features, making it calm and supportive.

**Takeaway:** Don't let "I'm not an expert in X" stop you. AI amplifies your intent, lets you operate at architecture/UX level, not syntax/boilerplate. Curiosity + the right tools = real software that helps people.


## Challenges & Gotchas

**Technical quirks Copilot helped solve:**
- HTTPoison dependency locks, Elm operator precedence, type name clashes
- Elm ports require `port module` declaration (not `module`)
- Alpine Linux needed ncurses-libs for Erlang runtime

**Copilot CLI observations:**
⚠️ Screen flickers if you enter a new prompt while previous one runs (similar to early Claude Code CLI—common in terminal AI tools)
⚠️ Occasional latency when multi-tasking

Not show-stoppers, just quirks to know.

## What Makes This Special

**For users:** No judgment, no timer, gentle feedback, local privacy
**For engineers:** "Boring" languages (Elm/Elixir) solve real problems, real-time architecture, local LLM (no API costs), type safety
**For community:** Open source, comprehensive docs, proof that one-day meaningful builds are possible with AI tools

## Final Thoughts

This POC is small, crazy, and deeply personal. I've faced stuttering struggles—I know how hard it is when therapy is expensive or inaccessible. I wanted to use my engineering skills to help, even in a tiny way.

Elm and Elixir: perfect for stable, real-time, calm experiences. GitHub Copilot CLI: made build/test/doc/deploy happen in one day.

Sometimes forgotten languages are magical. Sometimes AI is your sidekick. Sometimes local-first beats cloud everything. Sometimes a crazy idea becomes a meaningful tool for people who need it.

**PaceMate proves accessibility software doesn't need to be flashy—it needs to be thoughtful.**

---

📦 [**GitHub Repo**](https://github.com/ujjavala/GitHub-Copilot-CLI-Challenge-PaceMate)

**Built with ❤️ for people who stutter. Built fast with Elm, Elixir, and GitHub Copilot CLI.**