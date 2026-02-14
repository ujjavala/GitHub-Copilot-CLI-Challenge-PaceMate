# Quick Deploy Guide - PaceMate

Get PaceMate deployed to production in 5 minutes.

## Prerequisites

```bash
# Install Fly.io CLI
curl -L https://fly.io/install.sh | sh

# Login
flyctl auth login
```

---

## Backend (Fly.io) - 2 minutes

```bash
# 1. Create app
flyctl launch --name pacemate-backend --region sjc --no-deploy

# 2. Set secrets
flyctl secrets set SECRET_KEY_BASE="$(mix phx.gen.secret)"
flyctl secrets set PHX_HOST="pacemate-backend.fly.dev"

# 3. Deploy
flyctl deploy

# 4. Verify
flyctl status
curl https://pacemate-backend.fly.dev/api/health
```

**Backend URL:** `https://pacemate-backend.fly.dev`

---

## Frontend (Netlify) - 3 minutes

### Via Netlify UI (Easiest)

1. Go to https://app.netlify.com/
2. Click "Add new site" → "Import from Git"
3. Select your repository
4. Configure:
   ```
   Base directory: frontend
   Build command: npm install && npm run build:elm
   Publish directory: frontend
   ```
5. Add environment variable:
   ```
   BACKEND_URL=wss://pacemate-backend.fly.dev
   ```
6. Click "Deploy"

**Frontend URL:** `https://your-site-name.netlify.app`

---

## Update Frontend Code

Update WebSocket URL in your Elm app:

```elm
-- In Main.elm or wherever WebSocket connects
websocketUrl = "wss://pacemate-backend.fly.dev/socket"
```

Or in JavaScript:

```javascript
// frontend/src/index.js
const socket = new WebSocket("wss://pacemate-backend.fly.dev/socket")
```

Commit and push - Netlify will auto-deploy!

---

## Test Production

1. Open: `https://your-site-name.netlify.app`
2. Click "Start Session"
3. Verify WebSocket connects to backend

---

## Automatic Deployments

### GitHub Actions (Backend)

Already configured! Just push to `main`:

```bash
git add .
git commit -m "Deploy to production"
git push origin main
```

GitHub Actions will auto-deploy backend to Fly.io.

**Setup once:**
```bash
# Get Fly API token
flyctl auth token

# Add to GitHub Secrets:
# Repo → Settings → Secrets → Actions
# Name: FLY_API_TOKEN
# Value: [paste token]
```

### Netlify (Frontend)

Auto-deploys on push to `main`. No setup needed!

---

## Monitoring

**Backend:**
```bash
flyctl logs              # View logs
flyctl status            # Check status
flyctl dashboard         # Open dashboard
```

**Frontend:**
- https://app.netlify.com/sites/[your-site]/deploys

---

## Custom Domain (Optional)

### Backend

```bash
flyctl certs create api.yourdomain.com

# Add DNS records:
# A    api    [IP from above]
# AAAA api    [IPv6 from above]

flyctl secrets set PHX_HOST="api.yourdomain.com"
```

### Frontend

1. Netlify UI → Domain Settings → Add custom domain
2. Add DNS:
   ```
   A    @    75.2.60.5
   ```
3. Update WebSocket URL to use `wss://api.yourdomain.com`

---

## Costs

**Free Tier:**
- Fly.io: 3 free VMs (256MB)
- Netlify: 100GB bandwidth/month

**Total:** $0/month ✅

---

## Troubleshooting

**Backend not responding:**
```bash
flyctl logs
flyctl status
curl https://pacemate-backend.fly.dev/api/health
```

**Frontend not connecting to backend:**
- Check browser console
- Verify WebSocket URL uses `wss://` (not `ws://`)
- Check backend logs: `flyctl logs`

**Build failing:**
```bash
# Test locally first
cd backend && mix release
cd frontend && npm run build:elm
```

---

## What's Next?

1. ✅ Production deployed
2. Add custom domain
3. Set up monitoring/alerts
4. Add authentication
5. Scale as needed

See [DEPLOYMENT.md](DEPLOYMENT.md) for full guide.

---

**You're live! 🚀**
