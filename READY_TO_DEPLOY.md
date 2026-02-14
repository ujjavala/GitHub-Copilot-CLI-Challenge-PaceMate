# ✅ Ready to Deploy - PaceMate

Everything is configured and ready for production deployment! This guide will get you deployed in minutes.

---

## 🎯 What's Already Done

All configuration files are created and ready:

- ✅ [fly.toml](fly.toml) - Fly.io backend configuration
- ✅ [netlify.toml](netlify.toml) - Netlify frontend configuration
- ✅ [.github/workflows/deploy-backend.yml](.github/workflows/deploy-backend.yml) - GitHub Actions CI/CD
- ✅ [scripts/deploy.sh](scripts/deploy.sh) - Deployment helper script
- ✅ Health check endpoint at `/api/health`
- ✅ Auto-detecting WebSocket URLs (local vs production)
- ✅ Dockerfiles optimized for production
- ✅ Documentation complete

**You just need to run a few commands!**

---

## 🚀 Deploy Now (5 Minutes)

### Step 1: Deploy Backend to Fly.io (2 minutes)

```bash
# Install Fly.io CLI if needed
curl -L https://fly.io/install.sh | sh

# Add to PATH (if needed)
export PATH="$HOME/.fly/bin:$PATH"

# Login to Fly.io
flyctl auth login

# Deploy using helper script
./scripts/deploy.sh setup    # First time only - creates app and sets secrets
./scripts/deploy.sh backend  # Deploy!
```

**Alternative manual setup:**
```bash
# Create app
flyctl launch --name pacemate-backend --region sjc --no-deploy

# Generate and set secrets
SECRET_KEY=$(cd backend && mix phx.gen.secret)
flyctl secrets set SECRET_KEY_BASE="$SECRET_KEY"
flyctl secrets set PHX_HOST="pacemate-backend.fly.dev"

# Deploy
flyctl deploy
```

**Verify deployment:**
```bash
curl https://pacemate-backend.fly.dev/api/health
# Expected: {"status":"ok","service":"pacemate-backend"}
```

✅ **Backend is live!** → `https://pacemate-backend.fly.dev`

---

### Step 2: Deploy Frontend to Netlify (3 minutes)

#### Option A: Netlify UI (Recommended - Easiest)

1. **Go to Netlify:** https://app.netlify.com/
2. **Click:** "Add new site" → "Import an existing project"
3. **Connect:** GitHub → Select your repository
4. **Configure build settings:**
   ```
   Base directory: frontend
   Build command: npm install && npm run build:elm
   Publish directory: frontend
   ```
5. **Optional:** Add environment variable (Site Settings → Environment Variables):
   ```
   BACKEND_URL = pacemate-backend.fly.dev
   ```
6. **Click:** "Deploy site"
7. **Wait:** ~1-2 minutes for build to complete

✅ **Frontend is live!** → `https://your-site-name.netlify.app`

#### Option B: Netlify CLI

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Login
netlify login

# Build frontend
cd frontend
npm install
npm run build:elm
cd ..

# Deploy
netlify deploy --prod --dir=frontend
```

---

### Step 3: Enable GitHub Actions Auto-Deploy (1 minute)

This makes future deployments automatic when you push to `main`.

```bash
# Get your Fly.io API token
flyctl auth token

# Add to GitHub:
# 1. Go to: https://github.com/[your-username]/[your-repo]/settings/secrets/actions
# 2. Click: "New repository secret"
# 3. Name: FLY_API_TOKEN
# 4. Value: [paste the token from above]
# 5. Click: "Add secret"
```

Now every push to `main` automatically deploys your backend! 🎉

---

### Step 4: Test Production Deployment (1 minute)

**Test backend:**
```bash
curl https://pacemate-backend.fly.dev/api/health
```

**Test frontend:**
1. Open: `https://your-site-name.netlify.app`
2. Click "Start Session"
3. Check browser console - should see:
   ```
   [WebSocket] Connecting to: wss://pacemate-backend.fly.dev/socket/websocket
   [WebSocket] Connected to server
   ```

✅ **Everything works!**

---

## 📊 Deployment Summary

| Component | Platform | URL | Cost |
|-----------|----------|-----|------|
| **Backend** | Fly.io | `https://pacemate-backend.fly.dev` | $0/month (free tier) |
| **Frontend** | Netlify | `https://your-site.netlify.app` | $0/month (free tier) |
| **CI/CD** | GitHub Actions | Auto-deploy on push | $0/month (free tier) |
| **Total** | - | - | **$0/month** ✅ |

---

## 🎨 Custom Domain (Optional)

### Backend Custom Domain

```bash
# Add custom domain to Fly.io
flyctl certs create api.yourdomain.com

# Update DNS at your domain registrar:
# A    api    [IP from above command]
# AAAA api    [IPv6 from above command]

# Update secret
flyctl secrets set PHX_HOST="api.yourdomain.com"
```

### Frontend Custom Domain

1. **Netlify UI:** Site Settings → Domain Management → Add custom domain
2. **Enter domain:** `yourdomain.com`
3. **Update DNS:**
   ```
   A    @    75.2.60.5
   ```
4. **Wait:** ~1 hour for DNS propagation
5. **SSL:** Netlify automatically provisions SSL

---

## 📝 What Happens After You Push

### Automatic Deployment Flow

```
You push to main
    ↓
GitHub Actions triggers
    ↓
Backend deploys to Fly.io (~2 minutes)
    ↓
Health checks pass
    ↓
Deployment complete! ✅

Netlify watches repo
    ↓
Frontend builds (~1 minute)
    ↓
Deploys to CDN globally
    ↓
Cache invalidated
    ↓
Site live! ✅
```

**Total time from push to live:** ~3 minutes

---

## 🔍 Monitoring & Logs

### Backend (Fly.io)

```bash
# View live logs
flyctl logs

# Check status
flyctl status

# Open dashboard
flyctl dashboard

# SSH into VM (debugging)
flyctl ssh console

# Check metrics
flyctl metrics
```

### Frontend (Netlify)

```bash
# View deployment logs
netlify logs

# Check status
netlify status

# Open dashboard
netlify open
```

**Or visit:**
- Fly.io: https://fly.io/dashboard
- Netlify: https://app.netlify.com/

---

## 🛠️ Helper Commands

```bash
# Deployment
./scripts/deploy.sh setup       # Initial setup (one-time)
./scripts/deploy.sh backend     # Deploy backend
./scripts/deploy.sh frontend    # Build frontend
./scripts/deploy.sh status      # Check deployment status
./scripts/deploy.sh logs        # View backend logs
./scripts/deploy.sh help        # Show all commands

# Fly.io
flyctl status                   # App status
flyctl logs                     # View logs
flyctl scale count 2            # Scale to 2 VMs
flyctl regions add lhr          # Add London region
flyctl secrets list             # List secrets
flyctl ssh console              # SSH into VM

# Netlify
netlify deploy --prod           # Manual deploy
netlify rollback                # Rollback to previous
netlify open                    # Open dashboard
```

---

## 🆘 Troubleshooting

### Backend Issues

**Health check failing:**
```bash
flyctl logs                    # Check error logs
flyctl ssh console             # SSH and debug
flyctl status                  # Check VM status
```

**WebSocket not connecting:**
```bash
flyctl logs                    # Check connection logs
# Verify PORT env var is 8080
# Verify health check endpoint works
curl https://pacemate-backend.fly.dev/api/health
```

### Frontend Issues

**Build failing:**
```bash
# Test locally first
cd frontend
npm install
npm run build:elm
```

**WebSocket connection refused:**
- Check browser console for exact error
- Verify backend URL in network tab
- Ensure backend is running: `curl https://pacemate-backend.fly.dev/api/health`

### Common Issues

**"App not found" on flyctl deploy:**
- Run `./scripts/deploy.sh setup` first

**"SECRET_KEY_BASE is missing":**
- Run `flyctl secrets set SECRET_KEY_BASE="$(cd backend && mix phx.gen.secret)"`

**Frontend shows "WebSocket connection failed":**
- Check backend health: `curl https://pacemate-backend.fly.dev/api/health`
- Check browser console for exact error
- Verify backend logs: `flyctl logs`

---

## ✅ Deployment Checklist

Before marking as "deployed":

- [ ] Fly.io CLI installed
- [ ] Logged in to Fly.io: `flyctl auth login`
- [ ] Backend deployed: `./scripts/deploy.sh backend`
- [ ] Backend health check passing: `curl https://pacemate-backend.fly.dev/api/health`
- [ ] Frontend deployed to Netlify
- [ ] Frontend can access backend (check browser console)
- [ ] GitHub Actions secret added (FLY_API_TOKEN)
- [ ] Tested on multiple devices
- [ ] All features working in production

---

## 📚 Full Documentation

For detailed information:

- **Quick Deploy:** [DEPLOY_QUICKSTART.md](DEPLOY_QUICKSTART.md) - This file!
- **Complete Guide:** [DEPLOYMENT.md](DEPLOYMENT.md) - Detailed deployment, scaling, monitoring
- **Main README:** [README.md](README.md) - Project overview and local setup
- **Architecture:** [ARCHITECTURE.md](ARCHITECTURE.md) - How everything works

---

## 🎉 You're Ready!

**Everything is configured. Just run:**

```bash
# 1. Deploy backend
./scripts/deploy.sh setup
./scripts/deploy.sh backend

# 2. Deploy frontend (via Netlify UI or CLI)
# https://app.netlify.com/

# 3. Test
curl https://pacemate-backend.fly.dev/api/health
open https://your-site.netlify.app
```

**That's it! You're live in production!** 🚀

---

## 💰 Cost Breakdown

**Free Tier Limits (More than enough for PaceMate):**

**Fly.io:**
- 3 shared-cpu VMs (256MB RAM each)
- 160GB outbound data transfer/month
- Sufficient for: 1000+ users, real-time WebSocket sessions

**Netlify:**
- 100GB bandwidth/month
- 300 build minutes/month
- Automatic SSL certificates
- Global CDN

**GitHub Actions:**
- 2000 minutes/month (free tier)
- Unlimited private repositories

**Total:** $0/month for POC/demo usage ✅

**Paid options (if you scale):**
- Fly.io: Additional VMs ~$5-10/month
- Netlify Pro: $19/month (more bandwidth)

---

**Questions?** Check [DEPLOYMENT.md](DEPLOYMENT.md) or create an issue on GitHub!

---

*Configuration complete. Ready to deploy. Go live!* 🎉
