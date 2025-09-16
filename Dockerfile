# Multi-stage Dockerfile for OvenPlayer
# Stage 1: Build the application
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Stage 2: Create production image with nginx
FROM nginx:alpine

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy built files from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html/dist
COPY --from=builder /app/demo /usr/share/nginx/html/demo
COPY --from=builder /app/src/assets /usr/share/nginx/html/src/assets

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Create index.html that redirects to demo
RUN echo '<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>OvenPlayer</title>
    <meta http-equiv="refresh" content="0; url=/demo/demo.html">
</head>
<body>
    <p>Redirecting to <a href="/demo/demo.html">OvenPlayer Demo</a>...</p>
</body>
</html>' > /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]