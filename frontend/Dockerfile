# Build stage - Compile Elm with dedicated Elm image
FROM elm:latest AS elm-builder

WORKDIR /app

# Copy Elm source
COPY frontend/src ./src
COPY frontend/elm.json .

# Compile Elm
RUN elm make src/Main.elm --output dist/elm.js

# Runtime stage
FROM node:20-alpine

WORKDIR /app

# Install serve to run static files
RUN npm install -g serve

# Copy compiled Elm output
COPY --from=elm-builder /app/dist ./dist
COPY frontend/index.html .

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1

# Start server
CMD ["serve", "-s", ".", "-l", "3000"]
