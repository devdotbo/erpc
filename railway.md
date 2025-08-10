# Railway CLI Guide for eRPC

This comprehensive guide documents all Railway CLI operations for the eRPC project, intended for developers and automation agents working with this deployment.

## Table of Contents
- [Installation](#installation)
- [Authentication](#authentication)
- [Project Setup](#project-setup)
- [Core Commands](#core-commands)
- [Environment Management](#environment-management)
- [Deployment Workflow](#deployment-workflow)
- [Monitoring & Debugging](#monitoring--debugging)
- [Advanced Operations](#advanced-operations)
- [Automation Scripts](#automation-scripts)
- [Troubleshooting](#troubleshooting)

## Installation

Railway CLI can be installed through multiple methods:

```bash
# macOS (Homebrew)
brew install railway

# Cross-platform (npm)
npm i -g @railway/cli

# Shell script installation
bash <(curl -fsSL cli.new)

# Windows (Scoop)
scoop install railway

# Verify installation
railway --version
```

Current version in use: railway 4.6.1

## Authentication

Railway supports multiple authentication methods:

### Interactive Login
```bash
# Browser-based authentication (recommended)
railway login

# Browserless login for CI/CD environments
railway login --browserless
```

### Token-based Authentication
```bash
# Project-level operations
export RAILWAY_TOKEN="your_project_token"

# Account/team-level operations
export RAILWAY_API_TOKEN="your_api_token"

# Verify authentication
railway whoami
```

## Project Setup

### Initial Project Setup
```bash
# Create new project
railway init --name erpc

# Link existing project
railway link
# Select: erpc project
# Select: production environment

# Link with specific parameters
railway link --project erpc --environment production

# Verify project linkage
railway status
```

### Service Management
```bash
# Link to specific service
railway service erpc

# List available services
railway service

# Unlink from current project
railway unlink
```

## Core Commands

### 1. Project Information (`railway status`)
```bash
# Show current project status
railway status

# Expected output:
# Project: erpc
# Environment: production
# Service: erpc
```

### 2. Environment Variables (`railway variables`)
```bash
# List all variables
railway variables

# List in key=value format
railway variables --kv

# Output as JSON
railway variables --json

# Set variables (triggers deployment)
railway variables --set "ANKR_API_KEY=your_key" --set "LOG_LEVEL=info"

# Set without triggering deployment
railway variables --set "KEY=value" --skip-deploys

# Set for specific service
railway variables --service erpc --set "PORT=4000"
```

### 3. Local Development (`railway run`)
```bash
# Run with Railway environment variables
railway run make run

# Run specific command
railway run go test ./...

# Use specific service variables
railway run --service erpc make test

# Use specific environment
railway run --environment staging make run
```

### 4. Deployment (`railway up`)
```bash
# Deploy current directory
railway up

# Deploy detached (no log streaming)
railway up --detach

# Deploy with CI mode (logs only, then exit)
railway up --ci

# Deploy specific path
railway up ./dist

# Deploy to specific service
railway up --service erpc

# Deploy with verbose output
railway up --verbose

# Deploy ignoring .gitignore
railway up --no-gitignore
```

### 5. Logging (`railway logs`)
```bash
# View latest deployment logs
railway logs

# View build logs
railway logs --build

# View deployment logs
railway logs --deployment

# View logs for specific deployment
railway logs <deployment-id>

# Output logs as JSON
railway logs --json

# Stream logs continuously
railway logs -f

# Logs from specific service
railway logs --service erpc
```

### 6. SSH Access (`railway ssh`)
```bash
# Open interactive shell
railway ssh

# Execute single command
railway ssh ls -la

# SSH to specific service
railway ssh --service erpc

# SSH with tmux session
railway ssh --session
railway ssh --session my-debug-session

# SSH to specific deployment instance
railway ssh --deployment-instance <instance-id>
```

## Environment Management

### Creating and Switching Environments
```bash
# List environments
railway environment

# Create new environment
railway environment new staging

# Switch to environment
railway environment staging

# Delete environment
railway environment delete staging

# Link to specific environment
railway link --environment staging
```

### Environment-specific Operations
```bash
# Deploy to staging
railway up --environment staging

# View staging variables
railway variables --environment staging

# Run with staging variables
railway run --environment staging make test
```

## Deployment Workflow

### Standard Deployment Process
```bash
# 1. Ensure you're in the correct project
railway status

# 2. Set/update environment variables
railway variables --set "ANKR_API_KEY=${ANKR_API_KEY}"
railway variables --set "REDIS_URL=redis://redis:6379"
railway variables --set "LOG_LEVEL=info"
railway variables --set "PORT=4000"
railway variables --set "METRICS_PORT=4001"

# 3. Deploy the application
railway up --detach

# 4. Monitor deployment
railway logs --build

# 5. Verify deployment
railway domain
```

### Docker-based Deployment
The project uses `Dockerfile.railway` for container builds:

```bash
# Railway automatically uses railway.toml configuration
# [build]
# builder = "DOCKERFILE"
# dockerfilePath = "Dockerfile.railway"

# Deploy triggers Docker build
railway up
```

### Rollback Deployment
```bash
# Remove most recent deployment
railway down

# Redeploy latest successful deployment
railway redeploy
```

## Monitoring & Debugging

### Health Checks
```bash
# Check service status
railway status

# View current deployments
railway logs --deployment

# Monitor resource usage (via dashboard)
railway open
```

### Debug Commands
```bash
# SSH for live debugging
railway ssh

# Check running processes
railway ssh ps aux

# View environment inside container
railway ssh env

# Check network connectivity
railway ssh curl -I http://localhost:4000/health

# Interactive debugging with tmux
railway ssh --session debug
```

### Performance Monitoring
```bash
# View Prometheus metrics endpoint
railway run curl http://localhost:4001/metrics

# Access Grafana dashboard (if configured)
# Use railway domain to get public URL
railway domain
```

## Advanced Operations

### Template Deployment
```bash
# Deploy from template
railway deploy --template postgres

# Deploy with variables
railway deploy --template postgres \
  --variable "POSTGRES_PASSWORD=secret" \
  --variable "POSTGRES_DB=erpc"

# Service-specific variables
railway deploy --template multi-service \
  --variable "Backend.PORT=3000" \
  --variable "Frontend.API_URL=http://backend:3000"
```

### Volume Management
```bash
# List volumes
railway volume

# Volume operations are typically managed via dashboard
railway open
```

### Database Operations
```bash
# Connect to database shell
railway connect

# For Redis
railway ssh redis-cli

# For PostgreSQL
railway ssh psql $DATABASE_URL
```

### Network Configuration
```bash
# Get public domain
railway domain

# Add custom domain
railway domain add api.example.com

# Generate Railway domain
railway domain generate
```

## Automation Scripts

### Development Script (`railway-dev.sh`)
```bash
#!/bin/bash
# Run eRPC locally with Railway environment
railway link
railway run make run
```

### Deployment Script (`deploy-railway.sh`)
```bash
#!/bin/bash
# Automated deployment with environment setup
railway whoami || railway login
railway init
railway link
railway variables --set "ANKR_API_KEY=$ANKR_API_KEY"
railway up --detach
railway logs -f
```

### Local Testing Script (`test-railway-local.sh`)
```bash
#!/bin/bash
# Test Railway Docker build locally
docker build -f Dockerfile.railway -t erpc-railway:test .
docker run --rm -p 4000:4000 -e ANKR_API_KEY="${ANKR_API_KEY}" erpc-railway:test
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Authentication Issues
```bash
# Clear credentials and re-login
railway logout
railway login

# Verify token is set correctly
echo $RAILWAY_TOKEN
```

#### 2. Deployment Failures
```bash
# Check build logs
railway logs --build

# Verify Dockerfile
cat Dockerfile.railway

# Test locally first
./test-railway-local.sh
```

#### 3. Environment Variable Issues
```bash
# List all variables
railway variables --json

# Verify variable is set
railway variables | grep ANKR_API_KEY

# Re-set if needed
railway variables --set "ANKR_API_KEY=${ANKR_API_KEY}"
```

#### 4. Service Connection Issues
```bash
# Check service status
railway status

# Re-link service
railway unlink
railway link --service erpc
```

#### 5. Network/Domain Issues
```bash
# Get current domain
railway domain

# Generate new domain if needed
railway domain generate

# Check internal networking
railway ssh ping redis.railway.internal
```

### Debug Mode Operations
```bash
# Enable verbose logging
railway up --verbose

# Set debug log level
railway variables --set "LOG_LEVEL=debug"

# SSH with debug session
railway ssh --session debug

# Monitor in real-time
railway logs -f | grep ERROR
```

## Best Practices

1. **Always verify project context** before operations:
   ```bash
   railway status
   ```

2. **Use detached deployments** for CI/CD:
   ```bash
   railway up --detach
   ```

3. **Set variables without deployment** when configuring:
   ```bash
   railway variables --set "KEY=value" --skip-deploys
   ```

4. **Use tmux sessions** for persistent debugging:
   ```bash
   railway ssh --session debug-$(date +%s)
   ```

5. **Export configuration** for backup:
   ```bash
   railway variables --json > railway-vars-backup.json
   ```

6. **Test locally** before deploying:
   ```bash
   ./test-railway-local.sh
   railway up --ci
   ```

## CI/CD Integration

### GitHub Actions Example
```yaml
- name: Deploy to Railway
  env:
    RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
  run: |
    npm i -g @railway/cli
    railway up --ci
```

### Environment Variable Management
```bash
# Development
railway variables --environment development --set "LOG_LEVEL=debug"

# Staging
railway variables --environment staging --set "LOG_LEVEL=info"

# Production
railway variables --environment production --set "LOG_LEVEL=error"
```

## Quick Reference

| Command | Description | Example |
|---------|-------------|---------|
| `railway init` | Create new project | `railway init --name erpc` |
| `railway link` | Link to existing project | `railway link --project erpc` |
| `railway up` | Deploy current directory | `railway up --detach` |
| `railway logs` | View deployment logs | `railway logs -f` |
| `railway run` | Run with env vars | `railway run make test` |
| `railway ssh` | SSH into service | `railway ssh --session` |
| `railway variables` | Manage env vars | `railway variables --kv` |
| `railway status` | Show project info | `railway status` |
| `railway down` | Remove latest deployment | `railway down` |
| `railway domain` | Get/set domain | `railway domain` |

## Notes for Automation Agents

When automating Railway operations:

1. Use `--ci` flag for non-interactive deployments
2. Set `RAILWAY_TOKEN` environment variable for authentication
3. Use `--json` output for parsing responses
4. Always check exit codes for command success
5. Use `--skip-deploys` when batch-setting variables
6. Implement retry logic for network operations
7. Parse `railway status` output to verify context before operations

## Additional Resources

- [Railway CLI Documentation](https://docs.railway.com/guides/cli)
- [Railway API Reference](https://docs.railway.com/reference/api)
- [eRPC Railway Template](https://railway.app/template/10iW1q)
- [Project Dashboard](https://railway.app)