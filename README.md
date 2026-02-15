# PaceMate

A sophisticated proof of concept for a mindful speaking practice companion with AI-powered feedback, built with Elm frontend and Elixir/Phoenix backend for real-time interaction.

## Quick Start

**Prerequisites:** Docker

### Just Run This
```bash
docker-compose --profile ai up --build
```

That's it! Everything builds and starts automatically:
- Backend with SQLite database
- Frontend with Elm
- Ollama AI service
- Migrations run automatically

**Access:**
- Practice UI: http://localhost:3000
- Analytics Dashboard: http://localhost:4000/dashboard

### Fresh Start (Optional)
```bash
# If you want to clean everything and start fresh
./docker-build-fresh.sh
```

### Without AI
```bash
docker-compose up --build
```

### Manual Development (No Docker)
```bash
# Terminal 1 - Backend
cd backend
mix deps.get && mix ecto.create && mix ecto.migrate
mix phx.server

# Terminal 2 - Frontend
cd frontend
npm install && npm run build:elm
python3 -m http.server 3000
```

## Key Features

### 🎤 AI Speech Analysis
- Pacing analysis with WPM calculation
- Personalized tips using local AI (Ollama phi3)
- Actionable guidance for breathing and rhythm
- Warm, supportive encouragement

### 📊 Analytics Dashboard
- Real-time tracking (SQLite local storage)
- Animated stats cards (sessions, words, WPM, streaks)
- WPM trend chart with gradient bars
- Practice frequency heatmap
- Milestone celebrations
- Privacy-preserving (all data local)

### 🎨 Professional UI
- Responsive design (mobile/tablet/desktop)
- Dark mode support
- Smooth animations
- WCAG compliant accessibility

### 🛠️ Technology Stack
- **Frontend**: Elm (type-safe functional)
- **Backend**: Elixir/Phoenix (real-time WebSocket)
- **Dashboard**: Phoenix LiveView (real-time UI)
- **Database**: SQLite (local-first)
- **AI**: Ollama/phi3 (local, private)

## Documentation

- [IMPLEMENTATION.md](./IMPLEMENTATION.md) - Dashboard details
- [BLOG.md](./BLOG.md) - Development blog
- [Documentation/](./Documentation/) - Full docs
- [ADR-001](./Documentation/adrs/ADR-001-local-first-analytics-dashboard.md) - Architecture decision

---

Built for accessibility and calm technology • Local-first • Privacy-preserving
