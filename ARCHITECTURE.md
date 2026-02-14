# Architecture & Design - PaceMate

## Overview

PaceMate is a proof of concept demonstrating a real-time, calm speaking practice application using:
- **Frontend**: Elm (type-safe state management, beautiful UI)
- **Backend**: Elixir/Phoenix (concurrent WebSocket handling, feedback generation)
- **Speech**: Web Speech API (browser-based real-time transcription)
- **AI**: Ollama/Phi3 (local LLM for personalized pacing analysis)
- **Communication**: Phoenix Channels via WebSocket

## Application Flow

```
User                Elm App              WebSocket           Phoenix Backend
 |                   |                      |                      |
 |--"Start"--------->|                      |                      |
 |                   |-- Join Channel ----->|-- phx_join -------->|
 |                   |<-- Ack -------------|<-- phx_reply --------|
 |                   |
 |<--Breathing-------|  (Idle → Breathing)
 |--"Ready"--------->|
 |                   |
 |<--Prompt---------|  (Breathing → Prompt)
 |--"Start"--------->|
 |                   |
 |<--Speaking------|  (Prompt → Speaking)
 |--"Done"--------->|-- finished_speaking->|-- process -------->|
 |                   |                      |-- generate feedback|
 |                   |<-- phx_reply --------|<-- feedback --------|
 |<--Feedback-------|  (Speaking → Feedback with feedback text)
 |--"Again"--------->|  (Feedback → Idle, restart)
 |
```

## Frontend Architecture (Elm)

### State Machine

```elm
type State
  = Idle
  | Breathing
  | Prompt
  | Speaking
  | Feedback

type alias Model =
  { state : State
  , feedback : Maybe Feedback
  , isLoading : Bool
  }

type alias Feedback =
  { encouragement : String
  , pacing : String
  , tips : String
  , metrics : Metrics
  }

type alias Metrics =
  { words : Int
  , sentences : Int
  , avgSentenceLength : Float
  , estimatedWpm : Float
  }
```

### Key Components

1. **Model** - Single `Model` type representing application state
2. **Update** - Pure functions mapping `Msg` to new `Model`
3. **View** - Renders different UI for each `State`
4. **Ports** - JavaScript interop for WebSocket communication

### Message Flow

```
User Event (Click) 
    ↓
    Elm Update (pure function)
    ↓
    Model changes + Cmd to send WebSocket message
    ↓
    Port (send) triggers JavaScript
    ↓
    JavaScript sends via WebSocket
    ↓
    (later) Server responds
    ↓
    JavaScript receives, sends via Port (recv)
    ↓
    Elm Update receives message
    ↓
    Model + View update
```

## Backend Architecture (Elixir/Phoenix)

### Channel Structure

```
UserSocket (lib/backend_web/channels/user_socket.ex)
  ↓
  └─ SessionChannel (lib/backend_web/channels/session_channel.ex)
      ├─ join/3      - Handle client connection
      ├─ handle_in/3 - Process client messages
      │   ├─ "finished_speaking" → generate feedback
      │   └─ "restart_session"   → acknowledge restart
      └─ handle_out/3 - (optional) broadcast to client
```

### Feedback Generation Pipeline

```
User sends speech text via WebSocket
  ↓
SessionChannel.handle_in receives "finished_speaking"
  ↓
Backend.AI.SpeechAnalysis.analyze_speech/1
  ├─ Extract metrics (word count, sentences, WPM)
  ├─ Call Ollama API with Llama2
  └─ Parse AI response (TIPS + ENCOURAGEMENT)
  ↓
Return structured Feedback
  ├─ encouragement (from AI)
  ├─ pacing (calculated metrics)
  ├─ tips (from AI)
  └─ metrics (parsed)
  ↓
Send to client via Phoenix Channel
  ↓
Elm View renders beautiful feedback card
```

## WebSocket Protocol

### Phoenix Channel Messages

#### Join Channel
**Client → Server**
```json
{
  "topic": "session:user_session",
  "event": "phx_join",
  "payload": {},
  "ref": "1"
}
```

**Server → Client**
```json
{
  "topic": "session:user_session",
  "event": "phx_reply",
  "payload": {
    "status": "ok",
    "response": {}
  },
  "ref": "1"
}
```

#### Finished Speaking
**Client → Server**
```json
{
  "topic": "session:user_session",
  "event": "finished_speaking",
  "payload": {},
  "ref": "2"
}
```

**Server → Client**
```json
{
  "topic": "session:user_session",
  "event": "phx_reply",
  "payload": {
    "status": "ok",
    "response": {
      "feedback": "Nice pacing. Keep it gentle."
    }
  },
  "ref": "2"
}
```

## File Organization

### Backend

```
backend/
├── lib/
│   ├── backend/                    # Domain logic
│   │   ├── application.ex          # App startup
│   │   ├── feedback.ex             # Feedback generation
│   │   └── ...
│   ├── backend_web/                # Web layer
│   │   ├── channels/
│   │   │   ├── session_channel.ex  # Main channel
│   │   │   └── user_socket.ex      # WebSocket handler
│   │   ├── controllers/
│   │   │   └── page_controller.ex  # HTTP endpoints
│   │   ├── endpoint.ex             # WebSocket config
│   │   └── router.ex               # Route definitions
│   └── backend_web.ex              # Web module
├── test/
├── priv/
├── config/
├── mix.exs                         # Dependencies
└── mix.lock
```

### Frontend

```
frontend/
├── src/
│   ├── Main.elm                    # Elm app (state machine + UI)
│   └── index.js                    # WebSocket handler (if using webpack)
├── index.html                      # HTML shell (includes WebSocket logic)
├── elm.json                        # Elm dependencies
├── package.json                    # npm dependencies
└── webpack.config.js               # Build config (optional)
```

## Design Decisions

### Why Elm?

1. **Type Safety** - Compiler prevents entire classes of bugs
2. **Predictable State** - No hidden mutations or side effects
3. **Refactoring Confidence** - Compiler guides refactoring
4. **Perfect for UI** - State machine maps naturally to UI states
5. **Small Bundle** - Compiled Elm is ~120KB (unminified)

### Why Phoenix Channels?

1. **Built for WebSocket** - Channel protocol is elegant
2. **Scales Naturally** - Each client gets its own process
3. **Real-time First** - No polling, no fallbacks needed
4. **Easy Testing** - Can test channels like normal modules
5. **Integrated with Erlang** - Leverage supervision trees for reliability

### Why Ports (not a JavaScript WebSocket Library)?

1. **Educational** - Shows raw WebSocket protocol
2. **Minimal Dependencies** - No JavaScript frameworks needed
3. **Full Control** - See exactly what messages are sent/received
4. **Clear Boundaries** - JavaScript handles I/O, Elm handles logic

### Feedback Generation Strategy

**Hard-coded list of gentle messages**
- Pro: Simple, predictable
- Con: Not personalized
- Trade-off: POC uses static list; production could use ML models

## Performance Characteristics

### Frontend
- **Elm Compilation**: ~5 seconds
- **App Bundle**: ~120KB (unminified)
- **Initial Load**: ~1-2 seconds (including WebSocket handshake)
- **Memory**: ~5-10MB for single session

### Backend
- **Channel Join**: <1ms
- **Feedback Generation**: <1ms (string selection)
- **Message Throughput**: 100+ msg/sec per connection
- **Concurrent Sessions**: Erlang can handle 100k+ connections

## Limitations & Tradeoffs

| Aspect | Current | Production |
|--------|---------|-----------|
| Auth | None | OAuth / JWT |
| Database | None | PostgreSQL |
| Persistence | RAM only | Persistent storage |
| Speech analysis | None | Real ASR + analysis |
| Error handling | Minimal | Comprehensive logging |
| Monitoring | None | Prometheus metrics |
| Scalability | Single node | Cluster-ready |
| User management | None | User accounts |

## Extension Points

### Easy to Add:
- Different feedback strategies (rule-based, ML-based)
- User authentication (Pow, Guardian)
- Session persistence (Ecto)
- Multiple prompts/lessons
- Progress tracking
- Metrics/analytics

### Harder to Add:
- Real speech recognition (Web Audio API integration)
- Speech analysis (requires domain knowledge)
- Mobile app (rewrite in React Native / Flutter)
- Offline support (service workers)

## Security Considerations

### Current POC
- No authentication → anyone can connect
- No input validation → XSS possible
- No CORS setup → works only on same origin
- WebSocket unencrypted → use wss:// in production

### Production Checklist
- [ ] Implement authentication
- [ ] Validate all inputs
- [ ] Use TLS (wss://, https://)
- [ ] Set proper CORS headers
- [ ] Rate limit connections
- [ ] Add CSRF protection
- [ ] Implement audit logging
- [ ] Regular security updates

## Monitoring & Debugging

### Elm Debugging
```elm
-- Add Debug.log to trace values
Debug.log "feedback" feedback
```

### Elixir Debugging
```elixir
# IO.inspect for debugging
IO.inspect(feedback, label: "Feedback")

# Use :observer for process monitoring
:observer.start()
```

### WebSocket Debugging
Browser DevTools → Network tab → WS filter to see messages

## Testing Strategy

### Backend (Elixir)
```bash
mix test
```
- Channel tests in `test/backend_web/channels/`
- Use `Phoenix.ChannelTest` for message assertions

### Frontend (Elm)
```bash
# Test compilation
npx elm make src/Main.elm

# Manual testing in browser
```
- Elm's type system catches most bugs
- Browser devtools to trace state changes

## Build & Deployment

### Backend
```bash
MIX_ENV=prod mix release
```
Creates standalone Erlang release

### Frontend
```bash
cd frontend && npm run build
# Output in dist/elm.js
# Serve via web server or embed in backend
```

## Resources

- [Elm Guide](https://guide.elm-lang.org/)
- [Phoenix Channels](https://hexdocs.pm/phoenix/channels.html)
- [WebSocket Protocol](https://tools.ietf.org/html/rfc6455)
- [Erlang Supervision](https://learnyousomeerlang.com/supervisors)
