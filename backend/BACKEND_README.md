# Stutter-Accessibility POC - Backend

Elixir/Phoenix WebSocket backend for real-time speaking practice feedback.

## Features

- Phoenix Channels for WebSocket communication
- No authentication, no database (in-memory)
- Generates random gentle feedback messages
- Simple session management

## Setup

```bash
cd backend
mix deps.get
```

## Running

```bash
mix phx.server
```

The server runs on `http://localhost:4000` with WebSocket at `ws://localhost:4000/socket`.

## Architecture

### Channel: `session:user_session`

**Messages:**

- **Client → Server:** `finished_speaking`
  - Payload: `{}`
  - Server responds with random feedback

- **Client → Server:** `restart_session`
  - Payload: `{}`
  - Server acknowledges restart

**Example Response:**

```json
{
  "feedback": "Nice pacing. Keep it gentle."
}
```

## Files

- `lib/backend_web/channels/session_channel.ex` - Main channel handler
- `lib/backend_web/channels/user_socket.ex` - WebSocket connection
- `lib/backend/feedback.ex` - Feedback message generator
