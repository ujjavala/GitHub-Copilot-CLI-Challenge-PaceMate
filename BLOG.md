*This is a submission for the [GitHub Copilot CLI Challenge](https://dev.to/challenges/github-2026-01-21)*  

## What I Built

I went a little crazy 😎.

I decided to build a stutter-accessibility app in just one day. Why one day you ask? Well, I've been swamped for the last couple of weeks, and finally got some breathing space this weekend. So I figured, why not take this window and make something meaningful AND a little wild at the same time.

This project is deeply personal. I've faced my own challenges with stuttering, spent heaps of time and money on speech therapy, and realized that not everyone can afford professional support. That got me thinking. As an engineer, how can I use my skills to help the community?

Enter **PaceMate**: a calm, guided speaking experience built for people who stutter. Users can:

- **Start a session** 
- **Do a short breathing exercise** 
- **Read a prompt** 
- **Speak and practice** using Web Speech API for real-time transcription
- **Receive gentle AI-powered feedback** 
- **View detailed pacing metrics** 

## The Full Feature Set

### Core Experience

The app guides users through a **5-state speaking session**:
1. **Idle** - Calm welcome screen with session start button
2. **Breathing** - Animated breathing prompt with visual guide
3. **Prompt** - A short speaking prompt (no time pressure)
4. **Speaking** - User speaks and clicks "Done"
5. **Feedback** - AI-powered feedback + detailed speech metrics

### Advanced Features

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

**DevOps & Deployment**
- Docker (multi-stage builds for efficiency)
- Docker Compose (local development orchestration)
- Alpine Linux (lightweight runtime images)
- Health checks (service dependency management)
- Fly.io (backend hosting with auto-scaling)
- Netlify (frontend CDN with automatic HTTPS)
- GitHub Actions (CI/CD pipeline for auto-deployment)

**Testing**
- ExUnit (backend tests)
- Elm test (frontend tests)
- 33+ tests covering state transitions, JSON decoding, AI logic

## Demo & Repository

[**Demo Video**](https://youtu.be/qEtrt2MXVQA)

**For best experience fuelled with security and privacy, run the app on your local.**

[**Demo URL**](https://pace-mate.netlify.app/) - Note: The AI feedback is powered by a backend deployed on Fly.io, which is running on a 7-day free tier for this demo. After the free tier expires, the app will automatically fall back to rule-based feedback instead of AI analysis.

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
✅ **Helped configure Fly.io deployment** with optimal Phoenix settings
✅ **Suggested Netlify build commands** for Elm compilation
✅ **Accelerated documentation writing** - helped structure markdown files, suggested clear formatting, and ensured consistency across multiple docs (ARCHITECTURE.md, DEPLOYMENT.md, FEATURES.md, etc.)
✅ **Git workflow optimization** - suggested commit message conventions, helped structure the repository with proper .gitignore patterns, and guided branching strategies
✅ **CSS and styling suggestions** - provided responsive design patterns, suggested Font Awesome icon selections, and helped implement the calm, accessibility-focused color scheme
✅ **JSON encoding/decoding in Elm** - helped navigate Elm's JSON decoder patterns, especially for WebSocket message handling and complex nested data structures
✅ **Phoenix routing patterns** - suggested clean REST-style routes and WebSocket channel patterns that aligned with Elm's expectations
✅ **Error handling strategies** - recommended graceful fallback patterns for AI service unavailability and WebSocket disconnection scenarios
✅ **Docker multi-stage builds** - optimized Dockerfile structure to minimize image size while keeping build times reasonable
✅ **GitHub Actions workflow** - suggested CI/CD pipeline structure, health check patterns, and secret management best practices
✅ **Shell scripting helpers** - generated the deployment script (deploy.sh) with proper error handling and user-friendly output
✅ **Environment-specific configuration** - helped set up development vs. production WebSocket URLs, API endpoints, and feature flags

With Copilot, I could focus on making the app feel calm, human, and supportive, not fighting boilerplate or syntax. Even deployment configuration became straightforward with Copilot, suggesting best practices for Fly.io and Netlify. The CLI's ability to understand context across the entire project, from frontend Elm code to backend Elixir logic to DevOps scripts, meant I could stay in flow state and ship meaningful features instead of context-switching between documentation sites.

### Real Examples Where Copilot Saved Hours

**1. Elm State Machine Pattern**
When I asked Copilot to help scaffold the session state machine, it generated:
```elm
type SessionState
    = Idle
    | Breathing
    | ShowingPrompt
    | Speaking
    | ShowingFeedback FeedbackData

type Msg
    = StartSession
    | FinishBreathing
    | StartSpeaking
    | StopSpeaking
    | ReceiveFeedback String
```
This immediately gave me the exact architecture I needed—no trial and error.

**2. Phoenix Channel JSON Encoding**
Copilot suggested the idiomatic Elixir pattern for encoding speech metrics:
```elixir
def handle_in("speech_complete", %{"transcript" => transcript, "duration" => duration}, socket) do
  feedback = SpeechAnalyzer.analyze(transcript, duration)

  push(socket, "feedback", %{
    message: feedback.message,
    metrics: %{
      wpm: feedback.wpm,
      word_count: feedback.word_count,
      duration_seconds: duration
    }
  })

  {:noreply, socket}
end
```
Without Copilot, I would've spent time reading Phoenix docs for the exact pattern matching syntax.

**3. Docker Health Check**
When setting up the Dockerfile, Copilot generated this production-ready health check:
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:4000/api/health || exit 1
```
It even knew to use `wget` instead of `curl` for Alpine Linux!

**4. Elm JSON Decoder for WebSocket Messages**
One of Elm's trickier parts is JSON decoding. Copilot generated this decoder after I described the message structure:
```elm
feedbackDecoder : Decoder FeedbackData
feedbackDecoder =
    Decode.map3 FeedbackData
        (Decode.field "message" Decode.string)
        (Decode.field "wpm" Decode.int)
        (Decode.at ["metrics", "word_count"] Decode.int)
```
This saved me from debugging nested field access and type mismatches.

**5. GitHub Actions Deployment Workflow**
Copilot scaffolded the entire CI/CD pipeline with proper secrets handling:
```yaml
- name: Deploy to Fly.io
  env:
    FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
  run: |
    flyctl deploy --remote-only --ha=false
    flyctl status --json | jq '.status'
```
It even included the health check verification step I hadn't thought of!

**6. Responsive CSS Grid**
When building the metrics display, Copilot suggested this clean grid pattern:
```css
.metrics-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1.5rem;
    padding: 1rem;
}

@media (max-width: 768px) {
    .metrics-grid {
        grid-template-columns: 1fr;
    }
}
```
Perfect mobile-first responsive design without me having to look up the `auto-fit` vs `auto-fill` debate.

These weren't just syntax suggestions. Copilot understood the context of each language and framework, saving me from constant context-switching between documentation sites. That's what made the one-day sprint possible.

### A Note on Experience: Not an Expert, Just Determined

Here's the truth: **I'm not an Elm expert or an Elixir wizard.** I last touched Elixir close to 8 years ago, and Elm was completely new territory for me. Normally, diving into two "forgotten" functional languages for a one-day project would give me serious jitters, worrying about syntax quirks, type system gotchas, and framework patterns I'd have to learn from scratch.

But with GitHub Copilot CLI? **No jitters. Just flow.**

Copilot acted like a pair programmer who knew both languages inside-out. When I forgot Elixir's pattern-matching syntax, it filled in the gaps. When I was unsure about Elm's decoder patterns, it showed me the idiomatic way. When I couldn't remember if Phoenix used `push` or `broadcast` for WebSocket messages, Copilot just... knew.

**This is the magic of Copilot-CLI-assisted development**: you don't need to be an expert in every language to build something meaningful. You need curiosity, determination, and a tool that can bridge the knowledge gap in real-time. Copilot CLI was that bridge for me.

**I felt more like an architect than a coder.** My main focus was on the *why* and *how*—why does this state transition matter for users who stutter? How should the feedback feel supportive rather than judgmental? How do we handle WebSocket disconnections gracefully? Copilot took care of the *what*—what's the exact syntax for this Elm decoder? What's the idiomatic Elixir pattern for this channel handler? What Docker flags make this health check production-ready?

This role shift is profound. Instead of being stuck in syntax translation mode ("how do I write this in Elm again?"), I stayed in product thinking mode ("what experience do I want to create?"). The cognitive load dropped dramatically. I wasn't juggling language docs, Stack Overflow tabs, and error messages. I was designing, deciding, and directing. Copilot handled the translation from intent to implementation.

If I'd attempted this project 8 years ago without AI assistance, I'd have spent half the day reading docs and the other half debugging obscure compiler errors. Instead, I spent the day building features, testing flows, and making the app feel calm and supportive, exactly what it needed to be.

**The takeaway?** Don't let "I'm not an expert in X" stop you from building something. With the right tools, you can turn curiosity into capability, and capability into real software that helps people. AI doesn't replace your expertise. It amplifies your intent and lets you operate at the level of architecture and user experience, not syntax and boilerplate.


## Challenges & Interesting Discoveries

### Technical Challenges (Solved by Copilot, with love of course)

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

**PaceMate is proof that accessibility-focused software doesn't need to be flashy—it needs to be thoughtful.**

---

## GitHub Repository

👉 **[ujjavala/GitHub-Copilot-CLI-Challenge-PaceMate](https://github.com/ujjavala/GitHub-Copilot-CLI-Challenge-PaceMate)**

---

**Built with ❤️ for people who stutter. Built fast with Elm, Elixir, and GitHub Copilot CLI.**