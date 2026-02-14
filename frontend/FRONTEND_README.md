# PaceMate-Accessibility POC - Frontend

Elm single-page application with WebSocket integration for real-time speaking practice feedback.

## Features

- Clean, minimal UI optimized for calm interaction
- State machine managing session flow
- Real-time WebSocket communication with Phoenix backend
- No external dependencies for state management
- Responsive design for mobile and desktop

## Session Flow

1. **Idle** - User clicks "Start Session"
2. **Breathing** - Calm breathing prompt animation
3. **Prompt** - Speaking prompt displayed
4. **Speaking** - Indicator that microphone is listening (metaphorically)
5. **Feedback** - Receives gentle feedback from server

## Setup

```bash
cd frontend
npm install
```

## Development

```bash
npm run dev
```

Opens dev server on `http://localhost:3000`.

The app will automatically connect to the Phoenix backend on `ws://localhost:4000/socket/websocket`.

## Building

```bash
npm run build
```

Outputs compiled `elm.js` to `dist/` directory.

## Architecture

- **Main.elm** - Entry point with state machine and UI
- **index.js** - WebSocket connection and port handlers
- **index.html** - Styled HTML shell with WebSocket logic
- **webpack.config.js** - Build configuration

## How It Works

The Elm app uses **Ports** to communicate with JavaScript:

1. Elm sends messages via `send` port
2. JavaScript translates to Phoenix Channel protocol
3. Backend sends feedback response
4. JavaScript translates back and sends via `recv` port
5. Elm updates state with feedback

## WebSocket Protocol

**Join channel:**
```json
{ "topic": "session:user_session", "event": "phx_join", "payload": {}, "ref": "1" }
```

**Send finished speaking:**
```json
{ "topic": "session:user_session", "event": "finished_speaking", "payload": {}, "ref": "..." }
```

**Receive feedback:**
```json
{ "topic": "session:user_session", "event": "phx_reply", "payload": { "response": { "feedback": "Nice pacing..." } } }
```
