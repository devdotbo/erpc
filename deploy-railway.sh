#!/bin/bash

# Railway Deployment Script for eRPC with Ankr Protocol
# This script guides you through deploying eRPC to Railway

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== eRPC Railway Deployment Script ===${NC}"
echo ""

# Check if Railway CLI is logged in
echo -e "${YELLOW}Checking Railway CLI authentication...${NC}"
if ! railway whoami &>/dev/null; then
    echo -e "${YELLOW}Please login to Railway:${NC}"
    railway login
fi

# Initialize Railway project
echo -e "${BLUE}Initializing Railway project...${NC}"
echo -e "${YELLOW}Choose option 2 (Empty Project) when prompted${NC}"
railway init

# Link to the repository
echo -e "${BLUE}Linking to GitHub repository...${NC}"
railway link

# Add Redis service
echo -e "${BLUE}Adding Redis service to Railway...${NC}"
echo -e "${YELLOW}Please add Redis service manually in Railway dashboard:${NC}"
echo "1. Go to https://railway.app/project/2f42755f-4e46-4ffe-b09e-37f250eba910"
echo "2. Click 'New' -> 'Database' -> 'Add Redis'"
echo "3. Press Enter here once Redis is added..."
read -p ""

# Set environment variables
echo -e "${GREEN}Setting up environment variables...${NC}"
echo -e "${YELLOW}Please enter your Ankr API key:${NC}"
read -s ANKR_API_KEY
echo ""

# Set the environment variables in Railway
railway variables set ANKR_API_KEY="$ANKR_API_KEY"
railway variables set LOG_LEVEL="info"
railway variables set PORT="4000"
railway variables set METRICS_PORT="4001"

# Get Redis URL from Railway
echo -e "${BLUE}Configuring Redis connection...${NC}"
REDIS_URL=$(railway variables get REDIS_URL 2>/dev/null || echo "")
if [ -z "$REDIS_URL" ]; then
    echo -e "${YELLOW}Redis URL will be configured automatically by Railway${NC}"
else
    echo -e "${GREEN}Redis URL configured: ${REDIS_URL:0:30}...${NC}"
fi

# Deploy to Railway
echo -e "${GREEN}Deploying to Railway...${NC}"
railway up -d

# Get deployment URL
echo -e "${BLUE}Getting deployment information...${NC}"
sleep 5
DEPLOYMENT_URL=$(railway domain 2>/dev/null || echo "")

echo ""
echo -e "${GREEN}=== Deployment Complete ===${NC}"
echo ""
echo -e "${GREEN}Your eRPC instance is being deployed to Railway!${NC}"
echo ""
echo -e "${YELLOW}Important next steps:${NC}"
echo "1. Visit your Railway dashboard to monitor deployment: https://railway.app"
echo "2. Check the deployment logs: railway logs"
echo "3. Once deployed, your endpoints will be available at:"
echo "   - Base: https://[your-domain]/main/evm/8453"
echo "   - Optimism: https://[your-domain]/main/evm/10"
echo ""
echo -e "${BLUE}Useful Railway commands:${NC}"
echo "  railway logs          - View deployment logs"
echo "  railway status        - Check deployment status"
echo "  railway variables     - View/edit environment variables"
echo "  railway domain        - Get your deployment URL"
echo "  railway up -d         - Redeploy after changes"
echo ""

# Show logs
echo -e "${YELLOW}Showing deployment logs (Ctrl+C to exit):${NC}"
railway logs -f