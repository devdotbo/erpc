# Railway Deployment Guide for eRPC

This guide walks you through deploying eRPC with Ankr Protocol to Railway.

## Prerequisites

1. **Railway Account**: Sign up at [railway.app](https://railway.app)
2. **Railway CLI**: Already installed ✅
3. **Ankr API Key**: Get from [ankr.com/rpc](https://www.ankr.com/rpc/)
4. **GitHub Repository**: Already configured ✅

## Quick Deploy

Run the automated deployment script:

```bash
./deploy-railway.sh
```

This script will:
1. Authenticate with Railway
2. Create a new project
3. Add Redis service
4. Configure environment variables
5. Deploy your application

## Manual Deployment Steps

### 1. Login to Railway CLI

```bash
railway login
```

### 2. Initialize Railway Project

```bash
railway init
```

Choose "Empty Project" when prompted.

### 3. Link Your Repository

```bash
railway link
```

Select your repository from the list.

### 4. Add Redis Service

```bash
railway add -p redis
```

### 5. Configure Environment Variables

Set the required environment variables:

```bash
# Required
railway variables set ANKR_API_KEY="your_ankr_api_key_here"

# Optional (defaults shown)
railway variables set LOG_LEVEL="info"
railway variables set PORT="4000"
railway variables set METRICS_PORT="4001"
```

Railway will automatically set `REDIS_URL` for the Redis connection.

### 6. Deploy

```bash
railway up -d
```

### 7. Get Your Deployment URL

```bash
railway domain
```

## Configuration Details

### Dockerfile

Railway uses `Dockerfile.railway` which:
- Builds a minimal Alpine-based image
- Includes the production configuration (`erpc.prod.yaml`)
- Runs as non-root user for security
- Exposes ports 4000 (API) and 4001 (metrics)

### Railway.toml

Configures:
- Docker build settings
- Restart policy (3 retries on failure)
- Service ports mapping

### Environment Variables

| Variable | Required | Description | Default |
|----------|----------|-------------|---------|
| `ANKR_API_KEY` | ✅ | Your Ankr Protocol API key | - |
| `REDIS_URL` | ✅ | Redis connection URL (auto-set by Railway) | - |
| `PORT` | ❌ | HTTP API port | 4000 |
| `METRICS_PORT` | ❌ | Prometheus metrics port | 4001 |
| `LOG_LEVEL` | ❌ | Logging level (debug, info, warn, error) | info |

## Endpoints

Once deployed, your eRPC instance will be available at:

- **Base Chain**: `https://[your-railway-domain]/main/evm/8453`
- **Optimism Chain**: `https://[your-railway-domain]/main/evm/10`
- **Metrics**: `https://[your-railway-domain]:4001/metrics`

## Testing Your Deployment

Test Base network:
```bash
curl -X POST https://[your-railway-domain]/main/evm/8453 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "eth_blockNumber",
    "params": [],
    "id": 1
  }'
```

Test Optimism network:
```bash
curl -X POST https://[your-railway-domain]/main/evm/10 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "eth_blockNumber",
    "params": [],
    "id": 1
  }'
```

## Monitoring

### View Logs
```bash
railway logs -f
```

### Check Status
```bash
railway status
```

### View Metrics
Visit `https://[your-railway-domain]:4001/metrics` for Prometheus metrics.

## Updating Your Deployment

1. Make changes locally
2. Commit and push to GitHub
3. Redeploy:
```bash
railway up -d
```

Or enable automatic deployments in Railway dashboard.

## Cost Optimization

### Railway Pricing
- **Hobby Plan**: $5/month includes $5 of usage
- **Pro Plan**: $20/month includes $20 of usage

### Tips to Reduce Costs
1. **Optimize Redis Usage**: Configure appropriate cache TTLs
2. **Rate Limiting**: Already configured for Ankr limits
3. **Monitor Metrics**: Track request patterns and optimize

### Estimated Monthly Costs
- Small usage (< 100K requests/day): ~$5-10
- Medium usage (100K-1M requests/day): ~$10-30
- High usage (> 1M requests/day): ~$30+

## Troubleshooting

### Deployment Fails

Check logs:
```bash
railway logs
```

Common issues:
1. **Missing ANKR_API_KEY**: Set the environment variable
2. **Redis connection error**: Ensure Redis service is added
3. **Port conflicts**: Check PORT environment variable

### High Latency

1. Check Railway region (use closest to your users)
2. Monitor Redis performance
3. Review rate limiting configuration

### Rate Limit Errors

Adjust rate limits in `erpc.prod.yaml`:
- Increase `maxCount` for higher limits
- Adjust `period` for different time windows

## Security Considerations

1. **API Key Security**: Never commit API keys to repository
2. **HTTPS Only**: Railway provides automatic SSL
3. **Non-root User**: Docker runs as non-root user
4. **Environment Variables**: Use Railway's secure variable storage

## Support

- **Railway Support**: [railway.app/help](https://railway.app/help)
- **eRPC Documentation**: [github.com/erpc/erpc](https://github.com/erpc/erpc)
- **Ankr Documentation**: [docs.ankr.com](https://docs.ankr.com)

## Next Steps

1. Set up monitoring dashboards
2. Configure alerting for errors
3. Implement custom authentication if needed
4. Scale horizontally with multiple instances
5. Add more blockchain networks as needed