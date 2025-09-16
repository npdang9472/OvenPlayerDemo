# OvenPlayer Docker Setup Guide

This guide provides comprehensive instructions for running OvenPlayer locally and deploying it using Docker containers.

## Prerequisites

- Node.js (version 16 or higher)
- npm
- Docker
- Docker Compose (optional but recommended)

## Project Overview

OvenPlayer is a JavaScript-based HTML5 video player that supports:
- WebRTC streaming with sub-second latency
- Low Latency HLS (LLHLS)
- Traditional HLS and MPEG-DASH
- Various subtitle formats (SMI, VTT, SRT)
- VAST/VPAID advertising

## Local Development Setup

### 1. Install Dependencies
```bash
cd "d:\KHTN\Demo Projects\OvenPlayer\OvenPlayer"
npm ci
```

### 2. Development Build (with auto-rebuild)
```bash
npm run watch
```
This creates files in the `dev/` directory and automatically rebuilds when you modify source code.

### 3. Production Build
```bash
npm run build
```
This creates optimized files in the `dist/` directory.

### 4. View the Demo
Open `demo/demo.html` in a web browser to see OvenPlayer in action.

## Docker Setup

### Option 1: Using Docker Compose (Recommended)

#### Production Deployment
```bash
# Build and run production version
docker-compose --profile production up --build -d

# Access at: http://localhost:8080
```

#### Development Setup
```bash
# Build and run development version with hot reloading
docker-compose --profile development up --build -d

# Access static files at: http://localhost:8082
# Development server at: http://localhost:3000
```

### Option 2: Manual Docker Commands

#### Build Production Image
```bash
# Build the production Docker image
docker build -t ovenplayer:latest .

# Run the container
docker run -d -p 8080:80 --name ovenplayer-prod ovenplayer:latest

# Access at: http://localhost:8080
```

#### Build Development Image
```bash
# Build development image
docker build -f Dockerfile.dev -t ovenplayer:dev .

# Run development container with volume mounting
docker run -d -p 3000:3000 -p 8081:8080 -v "$(pwd):/app" -v /app/node_modules --name ovenplayer-dev ovenplayer:dev

# Access development files at: http://localhost:3000
```

## Docker Hub Deployment

### 1. Tag and Push to Docker Hub

Replace `your-dockerhub-username` with your actual Docker Hub username:

```bash
# Build the image
docker build -t ovenplayer:latest .

# Tag for Docker Hub
docker tag ovenplayer:latest your-dockerhub-username/ovenplayer:latest
docker tag ovenplayer:latest your-dockerhub-username/ovenplayer:v0.10.45

# Login to Docker Hub
docker login

# Push to Docker Hub
docker push your-dockerhub-username/ovenplayer:latest
docker push your-dockerhub-username/ovenplayer:v0.10.45
```

### 2. Automated Build Script

Create a `docker-push.sh` (or `docker-push.bat` for Windows) script:

```bash
#!/bin/bash
# docker-push.sh

# Configuration
DOCKER_USERNAME="your-dockerhub-username"
IMAGE_NAME="ovenplayer"
VERSION=$(node -p "require('./package.json').version")

# Build image
echo "Building Docker image..."
docker build -t $IMAGE_NAME:latest .

# Tag images
echo "Tagging images..."
docker tag $IMAGE_NAME:latest $DOCKER_USERNAME/$IMAGE_NAME:latest
docker tag $IMAGE_NAME:latest $DOCKER_USERNAME/$IMAGE_NAME:v$VERSION

# Push to Docker Hub
echo "Pushing to Docker Hub..."
docker push $DOCKER_USERNAME/$IMAGE_NAME:latest
docker push $DOCKER_USERNAME/$IMAGE_NAME:v$VERSION

echo "Successfully pushed $DOCKER_USERNAME/$IMAGE_NAME:latest and $DOCKER_USERNAME/$IMAGE_NAME:v$VERSION"
```

Make it executable and run:
```bash
chmod +x docker-push.sh
./docker-push.sh
```

### 3. Pull and Run on Other Virtual Machines

Once pushed to Docker Hub, you can pull and run on any machine with Docker:

```bash
# Pull the latest image
docker pull your-dockerhub-username/ovenplayer:latest

# Run the container
docker run -d -p 8080:80 --name ovenplayer --restart unless-stopped your-dockerhub-username/ovenplayer:latest

# Or run specific version
docker run -d -p 8080:80 --name ovenplayer --restart unless-stopped your-dockerhub-username/ovenplayer:v0.10.45
```

### 4. Using Docker Compose on Remote Machines

Create a `docker-compose.prod.yml` for remote deployment:

```yaml
version: '3.8'
services:
  ovenplayer:
    image: your-dockerhub-username/ovenplayer:latest
    ports:
      - "80:80"
    restart: unless-stopped
    container_name: ovenplayer-production
```

Deploy on remote machine:
```bash
# Download compose file
curl -O https://raw.githubusercontent.com/your-repo/ovenplayer/main/docker-compose.prod.yml

# Run
docker-compose -f docker-compose.prod.yml up -d
```

## Container Management Commands

### Useful Docker Commands
```bash
# View running containers
docker ps

# View container logs
docker logs ovenplayer-prod

# Stop container
docker stop ovenplayer-prod

# Remove container
docker rm ovenplayer-prod

# Remove image
docker rmi ovenplayer:latest

# Execute commands in running container
docker exec -it ovenplayer-prod sh

# View container resource usage
docker stats ovenplayer-prod
```

### Container Health Check
```bash
# Check if the container is serving content
curl -I http://localhost:8080

# Should return HTTP 200 OK
```

## Environment Variables

You can customize the deployment using environment variables:

```bash
# Custom port
docker run -d -p 3000:80 -e PORT=3000 your-dockerhub-username/ovenplayer:latest

# Custom nginx configuration
docker run -d -p 8080:80 -v /path/to/custom/nginx.conf:/etc/nginx/conf.d/default.conf your-dockerhub-username/ovenplayer:latest
```

## Production Considerations

### 1. Reverse Proxy Setup
For production, consider using a reverse proxy like nginx or Traefik:

```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 2. SSL/TLS Configuration
For HTTPS, use Let's Encrypt with Certbot or load balancers like AWS ALB.

### 3. Scaling
Use Docker Swarm or Kubernetes for horizontal scaling:

```bash
# Docker Swarm example
docker service create --name ovenplayer --replicas 3 -p 8080:80 your-dockerhub-username/ovenplayer:latest
```

## Troubleshooting

### Common Issues

1. **Port already in use**
   ```bash
   # Find process using port 8080
   netstat -tulpn | grep :8080
   # Kill the process or use different port
   docker run -d -p 8081:80 ovenplayer:latest
   ```

2. **Build fails**
   ```bash
   # Clear Docker cache
   docker builder prune -a
   # Rebuild
   docker build --no-cache -t ovenplayer:latest .
   ```

3. **Permission issues (Linux)**
   ```bash
   # Run with proper permissions
   sudo docker run -d -p 8080:80 ovenplayer:latest
   ```

## File Structure

After setup, your project should have these additional files:
```
├── Dockerfile              # Production Dockerfile
├── Dockerfile.dev          # Development Dockerfile  
├── docker-compose.yml      # Multi-environment compose file
├── nginx.conf             # Nginx configuration
└── DOCKER_GUIDE.md        # This guide
```

## Next Steps

1. Customize the player configuration in `demo/demo.html`
2. Modify styling in `src/stylesheet/ovenplayer.less`
3. Add your own streaming sources
4. Integrate with OvenMediaEngine for low-latency streaming
5. Deploy to cloud platforms (AWS ECS, Google Cloud Run, etc.)