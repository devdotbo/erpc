#!/bin/bash

# Test Railway deployment locally

echo "=== Testing Railway Deployment Locally ==="
echo ""

# 1. Build the Docker image using Railway's Dockerfile
echo "Building Docker image..."
docker build -f Dockerfile.railway -t erpc-railway:test .

# 2. Run locally with test environment variables
echo ""
echo "Starting container with test configuration..."
docker run --rm \
  --name erpc-railway-test \
  -p 4000:4000 \
  -p 4001:4001 \
  -e ANKR_API_KEY="${ANKR_API_KEY:-test_key}" \
  -e REDIS_URL="redis://host.docker.internal:6379" \
  -e DATABASE_URL="postgresql://user:pass@host.docker.internal:5432/erpc" \
  -e LOG_LEVEL="debug" \
  -e PORT="4000" \
  -e METRICS_PORT="4001" \
  erpc-railway:test

# Note: Use host.docker.internal to connect to services running on your host machine