#!/bin/bash

# Run eRPC locally with Railway environment variables

echo "=== Running eRPC with Railway Environment ==="
echo ""
echo "This command will:"
echo "1. Pull environment variables from your Railway project"
echo "2. Start eRPC locally with those variables"
echo ""
echo "First, you need to link to your service."
echo "Run: railway link"
echo "Then select your project and service"
echo ""
echo "After linking, run:"
echo "railway run make run"
echo ""
echo "Or to run with specific service:"
echo "railway run --service erpc make run"