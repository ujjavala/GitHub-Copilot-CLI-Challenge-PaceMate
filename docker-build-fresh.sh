#!/bin/bash
set -e

echo "🧹 Cleaning up..."
docker-compose down -v --remove-orphans

echo "🚀 Starting fresh with AI (building as needed)..."
docker-compose --profile ai up --build --force-recreate
