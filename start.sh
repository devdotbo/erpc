#!/bin/bash

# eRPC Startup Script with Ankr Protocol
# This script loads environment variables and starts eRPC with proper configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== eRPC Startup Script ===${NC}"

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    echo "Please copy .env.example to .env and configure your Ankr API key"
    exit 1
fi

# Load environment variables
export $(cat .env | grep -v '^#' | xargs)

# Check for required API key
if [ "$ANKR_API_KEY" = "YOUR_ANKR_API_KEY_HERE" ] || [ -z "$ANKR_API_KEY" ]; then
    echo -e "${RED}Error: Please set your ANKR_API_KEY in the .env file${NC}"
    echo "Get your API key from: https://www.ankr.com/rpc/"
    exit 1
fi

# Check if Redis is running
echo -e "${YELLOW}Checking Redis connection...${NC}"
if ! nc -z ${REDIS_HOST:-localhost} ${REDIS_PORT:-6379} 2>/dev/null; then
    echo -e "${YELLOW}Redis is not running. Starting Redis with Docker...${NC}"
    docker-compose up -d redis
    sleep 2
fi

# Build eRPC if needed
if [ "$1" = "--build" ]; then
    echo -e "${YELLOW}Building eRPC...${NC}"
    make build
fi

# Run eRPC
echo -e "${GREEN}Starting eRPC with Ankr Protocol${NC}"
echo -e "  - Base Chain (8453)"
echo -e "  - Optimism Chain (10)"
echo -e "  - HTTP endpoint: http://localhost:${HTTP_PORT:-4000}"
echo -e "  - Metrics endpoint: http://localhost:${METRICS_PORT:-4001}/metrics"
echo ""

if [ -f ./bin/erpc-darwin ]; then
    # macOS binary
    ./bin/erpc-darwin
elif [ -f ./bin/erpc-linux ]; then
    # Linux binary
    ./bin/erpc-linux
else
    # Run with go run
    go run cmd/erpc/main.go
fi