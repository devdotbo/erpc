#!/bin/bash

# Complete Railway Setup Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Completing Railway Setup ===${NC}"
echo ""

# Check if ANKR_API_KEY is provided
if [ -z "$1" ]; then
    echo -e "${RED}Please provide your Ankr API key as an argument${NC}"
    echo "Usage: ./complete-railway-setup.sh YOUR_ANKR_API_KEY"
    exit 1
fi

ANKR_API_KEY=$1

echo -e "${YELLOW}Step 1: Linking to the main service${NC}"
echo "When prompted, select your main app service (not Redis)"
railway service

echo -e "${YELLOW}Step 2: Setting environment variables${NC}"
railway variables --set "ANKR_API_KEY=${ANKR_API_KEY}" \
                  --set "LOG_LEVEL=info" \
                  --set "PORT=4000" \
                  --set "METRICS_PORT=4001"

echo -e "${YELLOW}Step 3: Getting Redis URL${NC}"
echo "Switch to Redis service to get the connection URL"
echo "Run: railway service (and select Redis)"
echo "Then run: railway variables"
echo "Copy the REDIS_PRIVATE_URL value"
echo ""
echo -e "${YELLOW}Step 4: Setting Redis URL in main service${NC}"
echo "Switch back to main service: railway service (select main app)"
echo "Set Redis URL: railway variables --set \"REDIS_URL=<paste_redis_url_here>\""
echo ""

echo -e "${GREEN}Step 5: Deploy${NC}"
echo "Deploy your application:"
echo "railway up --detach"
echo ""

echo -e "${BLUE}Useful commands:${NC}"
echo "  railway logs          - View deployment logs"
echo "  railway status        - Check deployment status"
echo "  railway variables     - View environment variables"
echo "  railway domain        - Get your deployment URL"
echo ""

echo -e "${GREEN}Manual steps remaining:${NC}"
echo "1. Link to your main service: railway service"
echo "2. Set the variables for your service"
echo "3. Get Redis URL from Redis service"
echo "4. Set REDIS_URL in main service"
echo "5. Deploy with: railway up --detach"