# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies
COPY frontend/package*.json ./
RUN npm install --legacy-peer-deps

# Install Elm
RUN npm install -D elm

# Copy Elm source
COPY frontend/src ./src
COPY frontend/elm.json .

# Compile Elm
RUN npm run build

# Runtime stage
FROM node:20-alpine

WORKDIR /app

# Install serve to run static files
RUN npm install -g serve

# Copy compiled files
COPY --from=builder /app/dist ./dist
COPY frontend/index.html .

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1

# Start server
CMD ["serve", "-s", ".", "-l", "3000"]
