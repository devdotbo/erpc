# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Development Commands

### Go Development
- **Setup dependencies**: `make setup`
- **Run the server**: `make run`
- **Build binaries**: `make build` (creates binaries in ./bin/)
- **Format code**: `make fmt`
- **Run tests**: 
  - Quick tests: `make test-fast` (no race detection)
  - Full test suite: `make test` (with race detection, ~8min timeout)
  - Single test: `LOG_LEVEL=trace go test -run <pattern> ./...`
  - Race condition testing: `make test-race` (runs tests 15 times with race detector)
  - Benchmarks: `make bench`
  - Coverage: `make coverage`

### TypeScript/Node Development
- **Install dependencies**: `pnpm install`
- **Build all packages**: `pnpm -r build`
- **Format TypeScript**: `pnpm -r run format` (uses Biome)

### Docker and Services
- **Start services**: `make up` (Redis, Postgres, ScyllaDB)
- **Stop services**: `make down`
- **Build Docker image**: `make docker-build platform=linux/amd64`
- **Run Docker image**: `make docker-run`

### Testing Infrastructure
- **Run k6 performance tests**: `make run-k6-evm-tip-of-chain` or `make run-k6-evm-historical-randomized`
- **Run fake RPCs for testing**: `make run-fake-rpcs`

## High-Level Architecture

eRPC is a fault-tolerant EVM RPC proxy that sits between clients and blockchain nodes. It provides intelligent request routing, caching, failover, and consensus mechanisms.

### Core Components

1. **ERPC Server** (`/erpc/erpc.go`): Main server orchestrating all components
   - Projects Registry: Manages multiple projects with their own networks and upstreams
   - Admin Auth Registry: Handles authentication for admin endpoints
   - Shared State Registry: Manages distributed state across instances

2. **Network Layer** (`/erpc/networks.go`): Handles blockchain network configurations
   - Manages multiple chains (identified by chainId)
   - Implements failsafe policies (timeout, retry, circuit breaker, hedge)
   - Consensus mechanisms for validating responses from multiple upstreams
   - Smart upstream selection based on health metrics

3. **Upstream Management** (`/upstream/`): Manages connections to RPC providers
   - Rate limiting per upstream
   - Health tracking and metrics
   - Dynamic upstream selection policies
   - Support for vendor-specific endpoints (Alchemy, Infura, etc.)

4. **Caching System** (`/data/`): Multi-tier caching with finality awareness
   - Memory cache for hot data
   - Redis for distributed caching
   - PostgreSQL/DynamoDB for permanent finalized data
   - Cache policies based on block finality (realtime, unfinalized, finalized)

5. **Consensus Engine** (`/consensus/`): Validates responses from multiple upstreams
   - Compares responses from multiple providers
   - Detects and handles chain reorganizations
   - Punishes nodes that consistently disagree
   - Supports different consensus policies (at least X nodes agree)

6. **Architecture Modules** (`/architecture/evm/`): EVM-specific logic
   - JSON-RPC method handlers (eth_call, eth_getLogs, etc.)
   - Block reference resolution
   - State polling for chain tips
   - Re-org detection and handling

## Testing Best Practices

### Always Initialize Test Logger
```go
func init() {
    util.ConfigureTestLogger()
}
```

### Gock HTTP Mocking
1. **Setup mocks BEFORE initializing components** (critical for avoiding race conditions)
2. Use standard pattern:
```go
util.ResetGock()
defer util.ResetGock()
util.SetupMocksForEvmStatePoller()
// Set up test-specific mocks here
// THEN initialize network/services
```
3. Use filters for distinguishing request types
4. Use `Persist()` for mocks called multiple times
5. Never use `t.Parallel()` with gock tests

### Context Management
- Always create and properly cancel contexts
- Pass context through all operations for proper cleanup

## Error Handling

### JSON-RPC Errors
- Use `common.HasErrorCode(err, codes...)` to check error codes
- Access normalized codes with `err.NormalizedCode()`
- Common codes:
  - `JsonRpcErrorEvmReverted` (3): EVM execution reverted
  - `JsonRpcErrorCallException` (-32000): Call exception
  - `JsonRpcErrorTransactionRejected` (-32003): Transaction rejected

### Consensus Errors
- Execution exceptions (like reverts) are valid consensus results
- Compare errors by normalized JSON-RPC codes, not types
- Count participants with consensus-valid errors as valid participants

## Configuration

The system uses a YAML configuration file (`erpc.yaml`) with these main sections:
- **database**: Cache connector configurations
- **server**: HTTP server settings
- **metrics**: Prometheus metrics endpoint
- **projects**: List of projects with networks and upstreams
- **upstreams**: RPC provider configurations with rate limits
- **failsafe**: Circuit breaker, retry, and timeout policies

## Important Implementation Notes

1. **Never modify upstream objects directly** - always check for nil
2. **Background processes start on initialization** - set up mocks before creating components
3. **Use vendor-specific endpoints** when available (e.g., `alchemy://API_KEY`)
4. **Rate limiters are shared** across upstreams via `rateLimitBudget`
5. **Cache policies are finality-aware** - different TTLs for different finality levels
6. **Consensus can be configured** per network with different participant requirements
7. **Health tracking** influences upstream selection automatically

## Common Debugging Commands

- View logs with different levels: `LOG_LEVEL=debug` or `LOG_LEVEL=trace`
- Run specific test: `go test -run TestName ./... -v`
- Check for race conditions: `go test -race ./...`
- Profile with pprof: `make run-pprof` (builds with pprof support)