# eRPC Configuration with Ankr Protocol

This setup configures eRPC as a fault-tolerant proxy for Base and Optimism chains using Ankr Protocol as the RPC provider.

## Architecture Overview

```
Client Apps
     ↓
   eRPC
     ├── Base (Chain ID: 8453)
     │   └── Ankr RPC Endpoint
     └── Optimism (Chain ID: 10)
         └── Ankr RPC Endpoint
```

## Features Configured

- **Multi-chain Support**: Base and Optimism networks
- **Intelligent Caching**: 
  - Memory cache for real-time data (2s TTL)
  - Redis cache for unfinalized data (30s TTL)
  - Redis cache for finalized data (24h TTL)
- **Fault Tolerance**:
  - Automatic retries with exponential backoff
  - Circuit breaker pattern
  - Request hedging for improved latency
- **Rate Limiting**: Configured for Ankr's API limits
- **Metrics**: Prometheus metrics endpoint

## Quick Start

### 1. Get Ankr API Key
Sign up for a free Ankr account at https://www.ankr.com/rpc/ and obtain your API key.

### 2. Configure Environment
Edit the `.env` file and replace `YOUR_ANKR_API_KEY_HERE` with your actual Ankr API key:

```bash
ANKR_API_KEY=your_actual_ankr_api_key_here
```

### 3. Start Services

#### Option A: Quick Start (Recommended)
```bash
# This will start Redis and eRPC automatically
./start.sh
```

#### Option B: Manual Setup
```bash
# Start Redis
docker-compose up -d redis

# Build eRPC
make build

# Run eRPC
make run
```

#### Option C: Docker Compose (All services)
```bash
# Start all services with Docker Compose
docker-compose up -d
```

### 4. Test the Setup

Test Base network:
```bash
curl -X POST http://localhost:4000/main/evm/8453 \
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
curl -X POST http://localhost:4000/main/evm/10 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "eth_blockNumber",
    "params": [],
    "id": 1
  }'
```

## Endpoints

- **Base RPC**: `http://localhost:4000/main/evm/8453`
- **Optimism RPC**: `http://localhost:4000/main/evm/10`
- **Metrics**: `http://localhost:4001/metrics`

## Configuration Details

### Rate Limiting
The configuration includes conservative rate limits for Ankr:
- General methods: 100 req/s
- eth_getLogs: 20 req/s
- Filters: 10 req/s
- Debug/Trace methods: 5 req/s

Adjust these in `.env` if you have a premium Ankr plan.

### Caching Strategy
- **Real-time data** (latest blocks): 2 second TTL in memory
- **Unfinalized data**: 30 second TTL in Redis
- **Finalized data**: 24 hour TTL in Redis

### Failsafe Configuration
- **Timeout**: 15s per request
- **Retries**: 3 attempts with exponential backoff
- **Circuit Breaker**: Opens after 5 failures
- **Hedging**: Sends duplicate request after 2s delay

## Advanced Configuration

### Enable PostgreSQL for Permanent Storage
Uncomment the PostgreSQL sections in:
1. `docker-compose.yml` - PostgreSQL service
2. `erpc.yaml` - postgres-cache connector

### Enable Monitoring
Uncomment the monitoring service in `docker-compose.yml` to enable Grafana dashboards.

### Add More Chains
Ankr supports many more chains. To add them:
1. Check supported chain IDs in `/thirdparty/ankr.go`
2. Add network configuration in `erpc.yaml`
3. Add upstream configuration with the appropriate chain ID

## Troubleshooting

### Redis Connection Error
```bash
# Start Redis manually
docker-compose up -d redis
```

### API Key Issues
- Ensure your Ankr API key is valid
- Check rate limit settings if getting 429 errors
- Verify the API key has access to Base and Optimism

### View Logs
```bash
# View eRPC logs with debug level
LOG_LEVEL=debug ./start.sh

# View Redis logs
docker-compose logs redis
```

## Performance Optimization

1. **Adjust Cache TTLs**: Modify TTL values in `erpc.yaml` based on your needs
2. **Scale Redis**: Use Redis cluster for high-traffic scenarios
3. **Add More Upstreams**: Configure multiple RPC providers for redundancy
4. **Tune Rate Limits**: Adjust based on your Ankr plan limits

## Security Notes

- Never commit `.env` file with real API keys
- Use environment variables in production
- Consider using secrets management system
- Enable authentication for production deployments

## Next Steps

1. Monitor metrics at `http://localhost:4001/metrics`
2. Configure alerting based on metrics
3. Add more chains as needed
4. Set up production deployment with proper secrets management