# Redis data store with Redis Insight

This group runs Redis and Redis Insight, the browser-based administration UI. Start with `docker compose up -d`, stop while retaining Redis and UI state with `docker compose stop`, or remove containers with `docker compose down`. Add `-v` to delete both named volumes; add `--rmi all` to remove images (`docker compose down --rmi all -v` resets the group).

## Redis

Redis is an in-memory data store with optional persistence. The server listens on `127.0.0.1:6379`; snapshots are enabled, with data stored in `redis_data`. No password is configured in this local-development stack.

- [Project and docs](https://redis.io/docs/latest/) · [Docker Hub](https://hub.docker.com/_/redis) · [GitHub](https://github.com/redis/redis)
- Isolated example: `docker run -d --name redis -p 127.0.0.1:6379:6379 -v redis_data:/data redis:latest redis-server --save 60 1 --loglevel warning`
- Options: persistent volume `redis_data:/data`; port `6379`; server arguments `--save 60 1 --loglevel warning`. Add Redis authentication before allowing access from other hosts.

## Redis Insight

Redis-maintained desktop-style web interface for inspecting and querying Redis. Open it at `http://127.0.0.1:5540`; it is configured to connect to the local service name `redis`.

- [Product and docs](https://redis.io/insight/) · [Docker Hub](https://hub.docker.com/r/redis/redisinsight) · [GitHub](https://github.com/RedisInsight/RedisInsight)
- Isolated example: `docker run -d --name redisinsight --network redis_default -p 127.0.0.1:5540:5540 -e RI_REDIS_HOST=redis -e RI_REDIS_PORT=6379 -e RI_REDIS_ALIAS=local-redis -v redisinsight_data:/data redis/redisinsight:latest`
- Options: persistent settings volume `redisinsight_data:/data`; port `5540`; `RI_REDIS_HOST`, `RI_REDIS_PORT`, `RI_REDIS_ALIAS`. Requires Redis on the same Docker network.
