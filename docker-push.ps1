# PowerShell script for pushing OvenPlayer to Docker Hub
# docker-push.ps1

# Configuration
$DOCKER_USERNAME = "your-dockerhub-username"
$IMAGE_NAME = "ovenplayer"

# Get version from package.json
$packageJson = Get-Content "package.json" -Raw | ConvertFrom-Json
$VERSION = $packageJson.version

Write-Host "Building Docker image..." -ForegroundColor Green
docker build -t ${IMAGE_NAME}:latest .

if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "Tagging images..." -ForegroundColor Green
docker tag ${IMAGE_NAME}:latest ${DOCKER_USERNAME}/${IMAGE_NAME}:latest
docker tag ${IMAGE_NAME}:latest ${DOCKER_USERNAME}/${IMAGE_NAME}:v${VERSION}

Write-Host "Pushing to Docker Hub..." -ForegroundColor Green
docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:latest
docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:v${VERSION}

if ($LASTEXITCODE -eq 0) {
    Write-Host "Successfully pushed ${DOCKER_USERNAME}/${IMAGE_NAME}:latest and ${DOCKER_USERNAME}/${IMAGE_NAME}:v${VERSION}" -ForegroundColor Green
} else {
    Write-Host "Push failed!" -ForegroundColor Red
    exit 1
}