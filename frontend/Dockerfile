# Runtime stage - serve pre-compiled Elm
FROM node:20-alpine

WORKDIR /app

# Install serve to run static files
RUN npm install -g serve

# Copy the pre-compiled dist directory and static files
COPY frontend/dist ./dist
COPY frontend/src ./src
COPY frontend/index.html .
COPY frontend/styles.css .

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1

# Start server
CMD ["serve", "-s", ".", "-l", "3000"]
