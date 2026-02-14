#!/bin/bash

# PaceMate Deployment Script
# Usage: ./scripts/deploy.sh [backend|frontend|all]

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}→${NC} $1"
}

check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 is not installed. Please install it first."
        exit 1
    fi
}

deploy_backend() {
    print_info "Deploying backend to Fly.io..."

    # Check if flyctl is installed
    check_command flyctl

    # Check if app exists
    if ! flyctl status &> /dev/null; then
        print_error "Fly.io app not found. Run setup first."
        exit 1
    fi

    # Deploy
    flyctl deploy

    # Verify
    print_info "Verifying deployment..."
    sleep 5

    BACKEND_URL=$(flyctl status --json | grep -o '"Hostname":"[^"]*"' | cut -d'"' -f4)

    if curl -s "https://$BACKEND_URL/api/health" | grep -q "ok"; then
        print_success "Backend deployed successfully!"
        print_success "URL: https://$BACKEND_URL"
    else
        print_error "Backend health check failed"
        exit 1
    fi
}

deploy_frontend() {
    print_info "Building frontend..."

    # Check if npm is installed
    check_command npm

    # Navigate to frontend
    cd frontend

    # Install dependencies
    print_info "Installing dependencies..."
    npm install

    # Build Elm
    print_info "Compiling Elm..."
    npm run build:elm

    print_success "Frontend built successfully!"
    print_info "Deploy to Netlify via:"
    print_info "  1. Push to GitHub (auto-deploy)"
    print_info "  2. Or run: netlify deploy --prod --dir=frontend"

    cd ..
}

setup_backend() {
    print_info "Setting up backend on Fly.io..."

    check_command flyctl
    check_command mix

    # Check if logged in
    if ! flyctl auth whoami &> /dev/null; then
        print_error "Not logged in to Fly.io. Run: flyctl auth login"
        exit 1
    fi

    # Generate secret key
    print_info "Generating secret key..."
    SECRET_KEY_BASE=$(mix phx.gen.secret)

    # Create app
    print_info "Creating Fly.io app..."
    flyctl launch --name pacemate-backend --region sjc --no-deploy

    # Set secrets
    print_info "Setting secrets..."
    flyctl secrets set SECRET_KEY_BASE="$SECRET_KEY_BASE"
    flyctl secrets set PHX_HOST="pacemate-backend.fly.dev"

    print_success "Backend setup complete!"
    print_info "Run: ./scripts/deploy.sh backend"
}

show_help() {
    cat << EOF
PaceMate Deployment Script

Usage:
    ./scripts/deploy.sh [command]

Commands:
    backend         Deploy backend to Fly.io
    frontend        Build frontend (deploy via Netlify)
    all             Deploy both backend and frontend
    setup           Initial Fly.io setup
    status          Check deployment status
    logs            View backend logs
    help            Show this help message

Examples:
    ./scripts/deploy.sh setup           # First time setup
    ./scripts/deploy.sh backend         # Deploy backend only
    ./scripts/deploy.sh all             # Deploy everything

EOF
}

check_status() {
    print_info "Checking deployment status..."

    # Backend status
    if command -v flyctl &> /dev/null && flyctl status &> /dev/null; then
        print_success "Backend is running on Fly.io"
        flyctl status
    else
        print_error "Backend not deployed or Fly.io CLI not installed"
    fi

    echo ""

    # Frontend status
    if command -v netlify &> /dev/null; then
        print_success "Netlify CLI installed"
        netlify status || print_error "Frontend not deployed to Netlify"
    else
        print_info "Netlify CLI not installed (optional)"
    fi
}

view_logs() {
    print_info "Viewing backend logs..."
    check_command flyctl
    flyctl logs
}

# Main script
case "$1" in
    backend)
        deploy_backend
        ;;
    frontend)
        deploy_frontend
        ;;
    all)
        deploy_backend
        echo ""
        deploy_frontend
        ;;
    setup)
        setup_backend
        ;;
    status)
        check_status
        ;;
    logs)
        view_logs
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
