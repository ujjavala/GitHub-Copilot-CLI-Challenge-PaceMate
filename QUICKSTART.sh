#!/bin/bash

# Stutter-Accessibility POC - Quick Start Script

echo "🎯 Stutter-Accessibility POC - Quick Start"
echo "=========================================="
echo ""

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v elixir &> /dev/null; then
    echo "❌ Elixir not found. Install with: brew install elixir"
    exit 1
fi

if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Install from https://nodejs.org"
    exit 1
fi

echo "✅ Elixir $(elixir --version | head -1)"
echo "✅ Node $(node --version)"
echo ""

# Setup backend
echo "Setting up backend..."
cd backend
mix deps.get > /dev/null 2>&1
echo "✅ Backend dependencies installed"
echo ""

# Setup frontend
echo "Setting up frontend..."
cd ../frontend
npm install > /dev/null 2>&1
npx elm make src/Main.elm --output dist/elm.js > /dev/null 2>&1
echo "✅ Frontend compiled"
echo ""

# Instructions
echo "=========================================="
echo "Setup complete! To run:"
echo ""
echo "Terminal 1 - Backend:"
echo "  cd backend && mix phx.server"
echo ""
echo "Terminal 2 - Frontend:"
echo "  cd frontend && python3 -m http.server 3000"
echo ""
echo "Then open http://localhost:3000 in your browser"
echo "=========================================="
