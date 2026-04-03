FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --only=production || npm install --omit=dev

# Copy application code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3000

# [2026-03-26 Bugfix] Use the same container-local probe that succeeds interactively.
#
# The previous spider-based localhost check was intermittently failing even while
# the Express server was serving traffic, which blocked nginx from starting.
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
  CMD wget --quiet --output-document=- http://127.0.0.1:3000/health >/dev/null || exit 1

# Start application
CMD ["node", "src/index.js"]
