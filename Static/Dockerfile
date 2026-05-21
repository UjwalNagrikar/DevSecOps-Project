# Multi-stage build for production-hardened image
FROM node:18-alpine AS builder
WORKDIR /app
COPY . .
# Optionally bundle assets if needed
RUN npm ci --only=production 2>/dev/null || true

FROM nginx:1.25-alpine
RUN apk add --no-cache curl

# Create non-root user
RUN addgroup -g 1000 nginx_user && \
    adduser -D -u 1000 -G nginx_user nginx_user

# Configure Nginx with minimal exposure
COPY Static/nginx.conf /etc/nginx/nginx.conf
RUN rm -rf /usr/share/nginx/html/* && \
    mkdir -p /usr/share/nginx/html

# Copy application files
COPY Static/index.html /usr/share/nginx/html/
COPY Static/style.css /usr/share/nginx/html/
COPY Static/script.js /usr/share/nginx/html/

# Create writable directories for Nginx
RUN chown -R nginx_user:nginx_user /var/cache/nginx /var/log/nginx /run

# Health check endpoints
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Switch to non-root user
USER nginx_user

EXPOSE 8080

# Health endpoints
# /health - liveness probe (basic connectivity)
# /ready - readiness probe (application ready to serve)

CMD ["nginx", "-g", "daemon off;"]

