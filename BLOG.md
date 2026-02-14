# PaceMate: Building a Stutter-Accessibility App in One Day with Elm, Elixir, and AI

This is a submission for the **GitHub Copilot CLI Challenge**.

## What I Built

I went a little crazy 😎.

I decided to build a stutter-accessibility app in just one day—why one day? Well, I've been swamped for the last couple of weeks, and finally got some breathing space this weekend. So I figured, why not take this window and make something meaningful AND a little wild at the same time.

This project is deeply personal. I've faced my own challenges with stuttering, spent heaps of time and money on speech therapy, and realized that not everyone can afford professional support. That got me thinking: as an engineer, how can I use my skills to help the community?

Enter **PaceMate**: a calm, guided speaking experience built for people who stutter. Users can:

- **Start a session** 🟢
- **Do a short breathing exercise** 🌬️
- **Read a prompt** ✏️
- **Speak and practice** 🎤 (using Web Speech API for real-time transcription)
- **Receive gentle AI-powered feedback** 💬
- **View detailed pacing metrics** 📊

## The Full Feature Set

### Core Experience

The app guides users through a **5-state speaking session**:
1. **Idle** - Calm welcome screen with session start button
2. **Breathing** - Animated breathing prompt with visual guide
3. **Prompt** - A short speaking prompt (no time pressure)
4. **Speaking** - User speaks and clicks "Done"
5. **Feedback** - AI-powered feedback + detailed speech metrics

### Advanced Features (Often Missed in POC Descriptions)

**Real-Time Communication**
- WebSocket-powered via Phoenix Channels
- Low-latency feedback (under 500ms)
- Multiple concurrent sessions handled by isolated Erlang processes
- Graceful connection recovery

**AI-Powered Feedback Engine**
- **Primary**: Ollama + Phi3 (fully local, privacy-preserving)
- **Fallback**: Rule-based tips when AI unavailable
- Analyzes:
  - Words Per Minute (WPM) pacing
  - Sentence count and structure
  - Speech flow patterns
  - Estimated pause points for breath

**Metrics Display**
The app shows users:
- Speaking duration
- Recognized speech transcript
- Estimated word count
- Pacing analysis (fast/normal/slow)
- Sentence statistics
- Personalized pacing recommendations

**Professional UI/UX**
- Clean, distraction-free design with soft gradients
- Font Awesome 6 icon integration
- Dark mode support for comfortable long sessions
- Fully responsive (mobile, tablet, desktop)
- Accessibility-first design patterns
- Animated breathing guide with visual feedback

**Production-Ready Architecture**
- Docker containerization with multi-stage builds
- Health checks ensuring service dependencies
- Comprehensive error handling
- Modular, testable code structure
- 33+ automated tests (>85% coverage on critical paths)

**Developer Experience**
- Complete architecture documentation
- Feature breakdown docs
- Quick-start guide for local setup
- Docker Compose for single-command startup
- Git repository with clean commit history

## Why Elm & Elixir?

Because sometimes, the forgotten things are the coolest.

**Elm**: a functional frontend language with predictable state and zero runtime errors. Perfect for accessibility-focused UI: no crashes, no surprises, just smooth flows that users can rely on.
- **Type Safety**: Impossible to send malformed messages to the backend
- **Predictable State Machine**: 5 states, clear transitions, no hidden edge cases
- **Pure Functions**: UI logic is testable and reproducible

**Elixir**: a functional, concurrent backend language running on the Erlang VM. Real-time sessions? Multiple users talking at once? Crashes don't break the room? Check, check, check.
- **Lightweight Concurrency**: Each session is an isolated process (fault-tolerant)
- **Hot Code Reloading**: Update logic without restarting users
- **Pattern Matching**: Elegantly handle different message types from clients

Most people skip these languages because they "aren't popular." But for this app? They're perfect. Elm gives a safe, predictable UI for someone practicing speech. Elixir lets me manage real-time sessions and AI feedback without risking a messy backend. Sometimes, you have to pick the right tool for the mission, not the trend.

## How AI Fits In

AI provides gentle feedback after each speaking session using a **local Ollama + Phi3 pipeline**:

**Why Local LLM?**
- **Privacy**: Speech data never leaves the user's device/server
- **No API costs**: Ollama runs locally
- **Accessibility**: Doesn't require external API keys or internet

**Feedback Examples**
- "Nice pacing. Keep it gentle."
- "Try a soft start next time."
- "Good breath before speaking."
- "You're doing great. Take your time."
- "Slow down slightly to improve clarity."
- "Great control over pace. Well done!"

**Fallback System**
If Ollama isn't running, the app gracefully falls back to rule-based feedback (no broken experiences).

The Elm frontend displays feedback in a calm, distraction-free card layout, keeping the focus on the user's practice, not the tech.

## Tech Stack & Infrastructure

**Frontend**
- Elm 0.19.1 (typed, functional, zero runtime errors)
- WebSockets (Phoenix Channels protocol)
- CSS Grid + Flexbox (fully responsive)
- Font Awesome 6 (clean, accessible icons)

**Backend**
- Elixir 1.19.5 on Erlang/OTP 28
- Phoenix 1.8.3 (web framework)
- Phoenix Channels (WebSocket handler)
- HTTPoison 2.3.0 (Ollama API client)
- Speech metrics analyzer (custom Elixir logic)

**AI**
- Ollama (local LLM runner)
- Phi3 (language model - lightweight, fast, efficient)
- Speech metrics parser (custom Elixir logic)

**DevOps**
- Docker (multi-stage builds for efficiency)
- Docker Compose (local development orchestration)
- Alpine Linux (lightweight runtime images)
- Health checks (service dependency management)

**Testing**
- ExUnit (backend tests)
- Elm test (frontend tests)
- 33+ tests covering state transitions, JSON decoding, AI logic

## Demo & Repository

**Live Repository**: [GitHub - ujjavala/GitHub-Copilot-CLI-Challenge-PaceMate](https://github.com/ujjavala/GitHub-Copilot-CLI-Challenge-PaceMate)

**Quick Start** (for developers)
```bash
# Clone
git clone https://github.com/ujjavala/GitHub-Copilot-CLI-Challenge-PaceMate.git
cd github-challenge

# With AI (requires Ollama + Phi3 model)
docker-compose --profile ai up
# On first run, Phi3 will download (~2GB, ~2 minutes)

# Without AI (rule-based feedback only)
docker-compose up

# Then open http://localhost:3000
```

**Project Structure**
```
.
├── frontend/          # Elm app + WebSocket client
├── backend/           # Elixir/Phoenix server + AI pipeline
├── docker-compose.yml # Local dev orchestration
├── ARCHITECTURE.md    # Technical deep-dive
├── FEATURES.md        # Complete feature documentation
├── BRANDING.md        # Design system & guidelines
└── README.md          # Quick start
```

## My Experience with GitHub Copilot CLI

Copilot CLI was a game-changer. Here's what made the difference:

✅ **Scaffolded Elm state machines** in seconds instead of hours
✅ **Suggested Phoenix Channels boilerplate** that just worked
✅ **Assisted in integrating AI feedback logic** without getting lost in syntax
✅ **Enabled fast iteration** in the terminal—critical for a one-day sprint
✅ **Helped debug Docker errors** with specific Alpine package names
✅ **Generated comprehensive test cases** covering edge cases I might have missed

With Copilot, I could focus on making the app feel calm, human, and supportive, not fighting boilerplate or syntax.

## Challenges & Interesting Discoveries

### Technical Challenges (Solved)

1. **HTTPoison Dependency Lock** - Had to run `mix deps.get` to generate mix.lock entries
2. **Elm Operator Precedence** - Pipe operator has lower precedence than `<>` (string concat)
3. **Elm Type Name Clash** - Union constructors and type aliases share namespace
4. **Port Module Declaration** - Elm ports require `port module` declaration, not `module`
5. **Elm npm Package in Docker** - Linux binary download fails; solved by pre-compiling locally
6. **Erlang ncurses Runtime** - Alpine needed explicit ncurses-libs for Erlang runtime

### Observations About Copilot CLI

While GitHub Copilot CLI is amazing, there are a few things I noticed while building this POC:

⚠️ **Concurrent Prompts Issue**: If you try to enter a new prompt while a previous one is still running, the screen flickers and sometimes hangs. Worth keeping in mind for future development.

⚠️ **Minor Latency**: Occasional latency when switching between multiple tasks in the terminal.

**Interesting Note**: I noticed similar issues with Claude Code CLI during its early phase—screen flickering, hangs when entering a new prompt while a previous one was running, etc. This seems to be a common quirk in terminal-based AI coding tools that stream outputs in real-time.

These aren't show-stoppers, but something to be aware of for future improvements and real-world workflow.

## What Makes This Special

### For Users with Stuttering
- **No judgment**: Just you and your words
- **No timer**: Speak at your own pace
- **Gentle feedback**: Encouragement, not criticism
- **Privacy**: AI runs locally on your device/server
- **Accessibility**: Calm UI, no flashing or pressure

### For Engineers
- **Language diversity**: Elm + Elixir show that "boring" languages solve real problems
- **Real-time architecture**: See how WebSockets and functional patterns work together
- **AI integration**: Local LLM pipeline without cloud costs or privacy concerns
- **Type safety**: Elm's type system prevents entire classes of bugs
- **Testability**: Functional architecture makes testing straightforward

### For the Community
- **Open source**: Build on it, fork it, make it yours
- **Documentation**: Learn from comprehensive guides and code
- **One-day POC**: Proof that meaningful software can be built fast with the right tools

## Final Thoughts

This POC is small, a little crazy, and deeply personal.

I've faced stuttering struggles myself, and I know how hard it can be when therapy is expensive or inaccessible.
I wanted to use my engineering skills to help the community, even in a tiny way.
Elm and Elixir were perfect tools to make something stable, real-time, and calm.
GitHub Copilot CLI made it possible to build, test, document, and deploy in one day.

Sometimes, the forgotten languages are magical. Sometimes, AI is your sidekick. Sometimes, local-first architecture beats cloud everything. And sometimes, a little crazy idea can turn into a meaningful tool for people who really need it.

**PaceMate is proof that accessibility-focused software doesn't need to be complex—it needs to be thoughtful.**

---

## Resources & Documentation

- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - How everything fits together
- **[FEATURES.md](./FEATURES.md)** - Complete feature breakdown
- **[BRANDING.md](./BRANDING.md)** - Design system and visual identity
- **[DOCKER.md](./DOCKER.md)** - Containerization & deployment
- **[TESTING.md](./TESTING.md)** - Test coverage & strategies
- **[README.md](./README.md)** - Quick start guide

## GitHub Repository

👉 **[ujjavala/GitHub-Copilot-CLI-Challenge-PaceMate](https://github.com/ujjavala/GitHub-Copilot-CLI-Challenge-PaceMate)**

---

**Built with ❤️ for people who stutter. Built fast with Elm, Elixir, and GitHub Copilot CLI.**
