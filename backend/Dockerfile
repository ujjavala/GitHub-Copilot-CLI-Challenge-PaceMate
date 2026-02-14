# Build stage
FROM elixir:1.19-otp-28-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache git build-base

# Copy mix files
COPY backend/mix.exs backend/mix.lock ./

# Install Hex and Rebar
RUN mix local.hex --force && mix local.rebar --force

# Install dependencies
RUN mix deps.get --only prod && mix deps.compile

# Copy source
COPY backend/ .

# Compile release
RUN mix compile && \
    MIX_ENV=prod mix release

# Runtime stage
FROM alpine:3.23

WORKDIR /app

# Install runtime dependencies (including ncurses for Erlang)
RUN apk add --no-cache openssl libstdc++ ncurses-libs ncurses-terminfo-base bash

# Copy release from builder
COPY --from=builder /app/_build/prod/rel/backend ./

# Expose port (will use PORT env var, default 4000 for local, 8080 for Fly.io)
EXPOSE 4000
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD bin/backend eval "Application.ensure_started(:backend)"

# Start application
CMD ["bin/backend", "start"]
