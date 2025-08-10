#!/bin/bash

# Script to set Railway environment variables

echo "Setting Railway environment variables..."

# Check if ANKR_API_KEY is provided as argument
if [ -z "$1" ]; then
    echo "Usage: ./setup-railway-env.sh YOUR_ANKR_API_KEY"
    echo "Example: ./setup-railway-env.sh abc123def456..."
    exit 1
fi

ANKR_API_KEY=$1

# Set all required environment variables
railway variables --set "ANKR_API_KEY=${ANKR_API_KEY}" \
                  --set "LOG_LEVEL=info" \
                  --set "PORT=4000" \
                  --set "METRICS_PORT=4001" \
                  --set "REDIS_URL=redis://default:password@redis:6379"

echo "Environment variables set successfully!"
echo ""
echo "To view your variables, run: railway variables"
echo "To check deployment status, run: railway status"
echo "To view logs, run: railway logs"