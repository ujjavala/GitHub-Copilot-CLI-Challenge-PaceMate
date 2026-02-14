# Deployment Guide - PaceMate

Complete guide for deploying PaceMate to production using Fly.io (backend) and Netlify (frontend).

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Prerequisites](#prerequisites)
- [Backend Deployment (Fly.io)](#backend-deployment-flyio)
- [Frontend Deployment (Netlify)](#frontend-deployment-netlify)
- [Environment Variables](#environment-variables)
- [Custom Domain Setup](#custom-domain-setup)
- [Monitoring & Logs](#monitoring--logs)
- [Troubleshooting](#troubleshooting)

---

## Architecture Overview

```
┌─────────────────┐         ┌──────────────────┐
│   Netlify CDN   │────────▶│  Fly.io Backend  │
│  (Frontend)     │  WSS    │ (Elixir/Phoenix) │
│  Static Assets  │         │   WebSocket      │
└─────────────────┘         └──────────────────┘
                                     │
                                     ▼
                            ┌──────────────────┐
                            │   Fly.io VM      │
                            │   (Ollama/AI)    │
                            │    Optional      │
                            └──────────────────┘
```

**Key Features:**
- ✅ Zero-downtime deployments
- ✅ Automatic HTTPS/WSS
- ✅ Auto-scaling (Fly.io)
- ✅ Global CDN (Netlify)
- ✅ WebSocket support
- ✅ Health checks
- ✅ Free tier available

---

## Prerequisites

### Required Accounts

1. **Fly.io Account** (for backend)
   - Sign up at https://fly.io/
   - Install Fly CLI: `curl -L https://fly.io/install.sh | sh`
   - Login: `flyctl auth login`

2. **Netlify Account** (for frontend)
   - Sign up at https://netlify.com/
   - Or use Netlify CLI: `npm install -g netlify-cli`

3. **GitHub Account**
   - For automatic deployments via GitHub Actions

### Local Tools

```bash
# Check installations
flyctl version    # Fly.io CLI
node --version    # Node.js 20+
mix --version     # Elixir 1.19+
```

---

## Backend Deployment (Fly.io)

### Step 1: Initial Setup

```bash
# Navigate to project root
cd /path/to/github-challenge

# Create Fly.io app (first time only)
flyctl apps create pacemate-backend --org personal

# Set region (choose closest to your users)
# Options: sjc (San Jose), iad (Virginia), lhr (London), etc.
flyctl regions set sjc
```

### Step 2: Configure Secrets

Generate a secret key for Phoenix:

```bash
# Generate secret key
mix phx.gen.secret

# Set secrets in Fly.io
flyctl secrets set SECRET_KEY_BASE="<paste-your-secret-here>"
flyctl secrets set PHX_HOST="pacemate-backend.fly.dev"
```

### Step 3: Deploy Backend

```bash
# Deploy from project root
flyctl deploy

# Watch deployment progress
flyctl status

# Check logs
flyctl logs
```

**Expected Output:**
```
✓ App deployed successfully
✓ Health checks passing
→ https://pacemate-backend.fly.dev
```

### Step 4: Verify Backend

```bash
# Test health endpoint
curl https://pacemate-backend.fly.dev/api/health

# Expected response:
# {"status":"ok","service":"pacemate-backend"}
```

---

## Frontend Deployment (Netlify)

### Option A: Deploy via Netlify UI (Recommended)

1. **Connect Repository**
   - Go to https://app.netlify.com/
   - Click "Add new site" → "Import an existing project"
   - Choose GitHub and select your repository

2. **Configure Build Settings**
   ```
   Base directory: frontend
   Build command: npm install && npm run build:elm
   Publish directory: frontend
   ```

3. **Set Environment Variables**
   - Go to Site Settings → Environment Variables
   - Add:
     ```
     BACKEND_URL=https://pacemate-backend.fly.dev
     ```

4. **Deploy**
   - Click "Deploy site"
   - Wait for build to complete
   - Get URL: `https://your-site-name.netlify.app`

### Option B: Deploy via Netlify CLI

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Login
netlify login

# Navigate to frontend
cd frontend

# Build
npm install
npm run build:elm

# Deploy
cd ..
netlify deploy --dir=frontend --prod

# Follow prompts and get your URL
```

### Step 5: Update Frontend WebSocket URL

Update the WebSocket connection in your frontend to use the Fly.io backend:

```javascript
// frontend/src/index.js or Main.elm
const BACKEND_URL = "wss://pacemate-backend.fly.dev/socket"
```

---

## Environment Variables

### Backend (Fly.io)

Set via `flyctl secrets set`:

| Variable | Description | Example |
|----------|-------------|---------|
| `SECRET_KEY_BASE` | Phoenix secret key | Generate with `mix phx.gen.secret` |
| `PHX_HOST` | Backend hostname | `pacemate-backend.fly.dev` |
| `PHX_SERVER` | Enable Phoenix server | `true` (set in fly.toml) |
| `PORT` | Internal port | `8080` (set in fly.toml) |
| `OLLAMA_HOST` | Ollama API URL | `http://ollama-vm:11434` (optional) |

```bash
# Set secrets
flyctl secrets set SECRET_KEY_BASE="your-secret-key"
flyctl secrets set PHX_HOST="pacemate-backend.fly.dev"
```

### Frontend (Netlify)

Set via Netlify UI or `netlify.toml`:

| Variable | Description | Example |
|----------|-------------|---------|
| `BACKEND_URL` | Backend WebSocket URL | `wss://pacemate-backend.fly.dev` |
| `NODE_VERSION` | Node.js version | `20` (set in netlify.toml) |

---

## Custom Domain Setup

### Backend (Fly.io)

```bash
# Add custom domain
flyctl certs create api.yourdomain.com

# Add DNS records (at your domain registrar):
# Type: A     Name: api     Value: [Fly.io IP from above command]
# Type: AAAA  Name: api     Value: [Fly.io IPv6 from above command]

# Verify
flyctl certs check api.yourdomain.com
```

Update secrets:
```bash
flyctl secrets set PHX_HOST="api.yourdomain.com"
```

### Frontend (Netlify)

1. Go to Site Settings → Domain Management
2. Click "Add custom domain"
3. Enter your domain: `yourdomain.com`
4. Update DNS records:
   ```
   Type: A     Name: @     Value: 75.2.60.5
   Type: AAAA  Name: @     Value: 2606:4700:3033::6815:1d2d
   ```
5. Netlify automatically provisions SSL

Update backend URL in Elm/JS:
```javascript
const BACKEND_URL = "wss://api.yourdomain.com/socket"
```

---

## Automatic Deployments (GitHub Actions)

The project includes a GitHub Actions workflow that automatically deploys on push to `main`.

### Setup GitHub Secrets

1. Go to GitHub repository → Settings → Secrets and variables → Actions
2. Add secrets:
   ```
   FLY_API_TOKEN: [Get from: flyctl auth token]
   ```

### Workflow Triggers

The workflow in [.github/workflows/deploy-backend.yml](.github/workflows/deploy-backend.yml) triggers on:
- Push to `main` branch
- Changes to `backend/**` or `fly.toml`

**Manual Trigger:**
```bash
# In GitHub UI: Actions → Deploy Backend → Run workflow
```

---

## Monitoring & Logs

### Backend (Fly.io)

```bash
# View real-time logs
flyctl logs

# View app status
flyctl status

# View app info
flyctl info

# SSH into VM (debugging)
flyctl ssh console

# View metrics
flyctl dashboard
```

### Frontend (Netlify)

```bash
# View deployment logs
netlify logs

# View site info
netlify status

# View analytics (in UI)
# Go to: https://app.netlify.com/sites/[your-site]/analytics
```

---

## Scaling

### Backend (Fly.io)

**Auto-scaling** (configured in fly.toml):
```toml
[http_service]
  auto_stop_machines = "stop"
  auto_start_machines = true
  min_machines_running = 0  # Scale to zero when idle (free tier)
```

**Manual scaling:**
```bash
# Scale to specific number of VMs
flyctl scale count 2

# Scale to different VM size
flyctl scale vm shared-cpu-2x --memory 512

# Scale to different regions
flyctl regions add lhr  # Add London
```

### Frontend (Netlify)

Netlify CDN automatically scales. No configuration needed.

---

## Ollama/AI Deployment (Optional)

To add AI features in production:

### Option 1: Separate Fly.io VM

```bash
# Create Ollama app
flyctl apps create pacemate-ollama

# Deploy Ollama
flyctl deploy --config fly-ollama.toml --dockerfile ollama.Dockerfile

# Update backend secret
flyctl secrets set OLLAMA_HOST="http://pacemate-ollama.internal:11434" -a pacemate-backend
```

### Option 2: External AI Service

Use OpenAI, Anthropic, or other hosted LLM services:

```bash
flyctl secrets set AI_API_KEY="your-api-key" -a pacemate-backend
flyctl secrets set AI_PROVIDER="openai" -a pacemate-backend
```

---

## Cost Estimates

### Free Tier Usage

**Fly.io Free Tier:**
- 3 shared-cpu-1x VMs (256MB each)
- 160GB outbound data transfer
- ✅ Sufficient for PaceMate backend

**Netlify Free Tier:**
- 100GB bandwidth/month
- 300 build minutes/month
- ✅ Sufficient for PaceMate frontend

**Total Cost:** $0/month (within free tiers)

### Paid Scaling (if needed)

**Fly.io:**
- Additional VMs: ~$5-10/month
- Larger VMs: ~$10-20/month
- Extra bandwidth: $0.02/GB

**Netlify:**
- Pro plan: $19/month (more bandwidth, build minutes)

---

## Troubleshooting

### Backend Issues

**Problem: Health checks failing**
```bash
# Check logs
flyctl logs

# Verify health endpoint locally
mix phx.server
curl http://localhost:4000/api/health

# Verify PORT env var
flyctl ssh console -C "env | grep PORT"
```

**Problem: WebSocket connection refused**
```bash
# Check runtime.exs port binding
# Ensure: http: [ip: {0, 0, 0, 0, 0, 0, 0, 0}]

# Check fly.toml internal_port matches PORT
```

**Problem: Deployment fails**
```bash
# Clean build
flyctl deploy --no-cache

# Check Dockerfile
docker build -f backend/Dockerfile .
```

### Frontend Issues

**Problem: Build fails on Netlify**
```bash
# Test build locally
cd frontend
npm install
npm run build:elm

# Check node version matches netlify.toml
node --version
```

**Problem: WebSocket not connecting**
- Check browser console for errors
- Verify backend URL uses `wss://` (not `ws://`)
- Check CORS settings in Phoenix

**Problem: Assets not loading**
- Verify paths in index.html are relative
- Check Netlify publish directory
- Clear browser cache

---

## Rollback

### Backend (Fly.io)

```bash
# List releases
flyctl releases

# Rollback to previous version
flyctl releases rollback
```

### Frontend (Netlify)

```bash
# Via UI: Deploys → [select previous deploy] → Publish deploy

# Via CLI
netlify rollback
```

---

## Production Checklist

Before going live:

- [ ] Backend deployed and health check passing
- [ ] Frontend deployed and accessible
- [ ] WebSocket connection working
- [ ] Environment variables set correctly
- [ ] Secrets configured (SECRET_KEY_BASE, etc.)
- [ ] Custom domain configured (optional)
- [ ] HTTPS/WSS enabled
- [ ] Monitoring set up
- [ ] GitHub Actions working
- [ ] Tested on multiple devices
- [ ] Performance tested

---

## Security Considerations

### Backend (Fly.io)

- ✅ HTTPS enforced (fly.toml)
- ✅ Secret key in environment variables (not committed)
- ✅ Health checks enabled
- ❌ TODO: Add rate limiting
- ❌ TODO: Add authentication

### Frontend (Netlify)

- ✅ Security headers configured (netlify.toml)
- ✅ HTTPS enforced automatically
- ❌ TODO: Add CSP headers

---

## Support & Resources

**Fly.io:**
- Docs: https://fly.io/docs/
- Community: https://community.fly.io/
- Status: https://status.fly.io/

**Netlify:**
- Docs: https://docs.netlify.com/
- Community: https://answers.netlify.com/
- Status: https://www.netlifystatus.com/

**PaceMate:**
- GitHub: [Your repo URL]
- Issues: [Your repo URL]/issues

---

## Next Steps

1. **Deploy Backend:**
   ```bash
   flyctl launch  # Initial setup
   flyctl deploy  # Deploy
   ```

2. **Deploy Frontend:**
   - Connect repo to Netlify
   - Configure build settings
   - Deploy

3. **Test:**
   - Open frontend URL
   - Start a session
   - Verify WebSocket connection

4. **Monitor:**
   - Check Fly.io dashboard
   - Check Netlify analytics

**You're live! 🎉**

---

*Last updated: 2026-02-15*
