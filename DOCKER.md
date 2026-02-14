# Docker & Running Guide

## Quick Start with Docker (Recommended)

### Prerequisites

- Docker Desktop (Mac/Windows) or Docker Engine (Linux)
- Docker Compose v2.0+

### Run Everything in One Command

```bash
docker-compose up
```

This will:
1. Build the backend (Elixir/Phoenix)
2. Build the frontend (Elm)
3. Start both services
4. Wait for services to be healthy
5. Expose frontend at http://localhost:3000

### Stop Everything

```bash
docker-compose down
```

---

## Docker Compose Services

### Services

**Backend (Elixir/Phoenix)**
- Port: 4000
- URL: http://localhost:4000
- Health check: Every 30s
- Environment: Production

**Frontend (Elm)**
- Port: 3000
- URL: http://localhost:3000
- Health check: Every 30s
- Depends on: Backend healthy

### Network

Services communicate over internal Docker network `stutter_network`

---

## Building Docker Images Manually

### Build Backend Image

```bash
docker build -f backend/Dockerfile -t pacemate-backend:latest .
```

### Build Frontend Image

```bash
docker build -f frontend/Dockerfile -t pacemate-frontend:latest .
```

### Run Backend Alone

```bash
docker run -p 4000:4000 \
  -e MIX_ENV=prod \
  -e PHX_HOST=localhost \
  pacemate-backend:latest
```

### Run Frontend Alone

```bash
docker run -p 3000:3000 pacemate-frontend:latest
```

---

## Docker Image Details

### Backend Image

**Base:** `elixir:1.19-otp-28-alpine`

**Stages:**
1. Builder: Compiles Elixir code and creates release
2. Runtime: Minimal Alpine image with only runtime deps

**Size:** ~200MB

**Entrypoint:** `bin/backend start`

### Frontend Image

**Base:** `node:20-alpine`

**Stages:**
1. Builder: Compiles Elm and generates elm.js
2. Runtime: Serves static files with `serve`

**Size:** ~100MB

**Entrypoint:** `serve -s . -l 3000`

---

## Running Tests in Docker

### Run Backend Tests

```bash
docker build -f backend/Dockerfile -t pacemate-test:latest .
docker run pacemate-test:latest mix test
```

### Run Frontend Tests

```bash
docker build -f frontend/Dockerfile -t pacemate-frontend-test:latest .
docker run pacemate-frontend-test:latest npm run test
```

### Run Both Tests

```bash
docker-compose run backend mix test
docker-compose run frontend npm run test
```

---

## Environment Variables

### Backend

```env
MIX_ENV=prod              # Production environment
PHX_HOST=localhost        # Phoenix host
PHX_PORT=4000            # Phoenix port
SECRET_KEY_BASE=...      # Session encryption key
```

### Frontend

```env
REACT_APP_API_URL=http://localhost:4000
```

---

## Debugging in Docker

### View Backend Logs

```bash
docker-compose logs backend
docker-compose logs -f backend  # Follow logs
```

### View Frontend Logs

```bash
docker-compose logs frontend
docker-compose logs -f frontend  # Follow logs
```

### Execute Command in Backend

```bash
docker-compose exec backend iex -S mix phx.server
```

### Execute Command in Frontend

```bash
docker-compose exec frontend sh
```

---

## Health Checks

Both services include health checks:

```bash
# Check service status
docker-compose ps

# Show health status
docker inspect <container-id> --format='{{.State.Health}}'
```

**Healthy statuses:**
- healthy: Service is running and responding
- starting: Service is initializing
- unhealthy: Service failed health check

---

## Production Deployment

### Build for Production

```bash
docker build -f backend/Dockerfile -t myregistry/pacemate-backend:1.0.0 .
docker build -f frontend/Dockerfile -t myregistry/pacemate-frontend:1.0.0 .
```

### Push to Registry

```bash
docker push myregistry/pacemate-backend:1.0.0
docker push myregistry/pacemate-frontend:1.0.0
```

### Deploy with Docker Compose

```bash
docker-compose -f docker-compose.yml \
  -f docker-compose.prod.yml \
  up -d
```

---

## Troubleshooting

### Backend Won't Start

```bash
# Check logs
docker-compose logs backend

# Rebuild without cache
docker-compose build --no-cache backend
```

**Common issues:**
- Secret key not set: Set `SECRET_KEY_BASE` env var
- Port already in use: Change port in `docker-compose.yml`

### Frontend Won't Start

```bash
# Check logs
docker-compose logs frontend

# Rebuild without cache
docker-compose build --no-cache frontend
```

**Common issues:**
- Backend not healthy: Ensure backend is running
- Port already in use: Change port in `docker-compose.yml`

### Connection Issues

```bash
# Test backend from frontend container
docker-compose exec frontend wget http://backend:4000

# Test frontend from host
curl http://localhost:3000
```

---

## Docker Compose Override File

For local development, create `docker-compose.override.yml`:

```yaml
version: '3.9'

services:
  backend:
    environment:
      - DEBUG=true
    volumes:
      - ./backend:/app

  frontend:
    environment:
      - DEBUG=true
    volumes:
      - ./frontend/dist:/app/dist
```

This enables hot-reloading and debugging.

---

## Performance Tips

### Speed Up Builds

```bash
# Use buildkit for faster builds
DOCKER_BUILDKIT=1 docker-compose build

# Build in parallel
docker-compose build --parallel
```

### Reduce Image Size

Use Alpine-based images (already done)
- Backend: 200MB
- Frontend: 100MB

---

## Cleanup

### Remove Stopped Containers

```bash
docker-compose down
```

### Remove All Images

```bash
docker rmi pacemate-backend pacemate-frontend
```

### Remove Unused Resources

```bash
docker system prune
```

---

## Using with Kubernetes

To deploy on Kubernetes, use the Docker images:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pacemate-backend
spec:
  containers:
  - name: backend
    image: myregistry/pacemate-backend:latest
    ports:
    - containerPort: 4000
```

---

**Docker makes deployment simple, consistent, and repeatable!** 🐳
