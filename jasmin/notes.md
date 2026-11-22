# Jasmin SMS gateway and SMPP server

This group combines the Jasmin gateway, its web panel and worker, Redis, RabbitMQ, and PostgreSQL. Start with `docker compose up -d`, stop without removing data with `docker compose stop`, or remove containers with `docker compose down`. Add `-v` to delete all persisted configuration and data; add `--rmi all` to remove images too (`docker compose down --rmi all -v` resets the group).

## Jasmin SMS Gateway

Open-source SMS gateway with SMPP client/server and HTTP API capabilities. The SMPP listener is `127.0.0.1:2775`, the management CLI is `127.0.0.1:8990`, and the HTTP API is `127.0.0.1:1401`.

- [Project and docs](https://docs.jasminsms.com/en/latest/) · [Docker Hub](https://hub.docker.com/r/jookies/jasmin) · [GitHub](https://github.com/jookies/jasmin)
- Isolated example: `docker run -d --name jasmin --network jasmin_default -p 127.0.0.1:2775:2775 -p 127.0.0.1:8990:8990 -p 127.0.0.1:1401:1401 -e REDIS_CLIENT_HOST=redis -e AMQP_BROKER_HOST=rabbitmq -e AMQP_BROKER_PORT=5672 -v jasmin_config:/etc/jasmin -v jasmin_logs:/var/log/jasmin jookies/jasmin:latest`
- Options: named volumes `jasmin_config:/etc/jasmin`, `jasmin_logs:/var/log/jasmin`; ports `2775`, `8990`, `1401`; `REDIS_CLIENT_HOST`, `AMQP_BROKER_HOST`, `AMQP_BROKER_PORT`. Requires Redis and RabbitMQ. CLI credentials: `jcliadmin` / `jclipwd`.

## Jasmin Web Panel

Browser interface to manage Jasmin connections, users, routes, filters, and message activity. Open `http://127.0.0.1:8999`; initial panel login is `admin` / `secret`.

- [Panel project and docs](https://about.supernovasoft.com/jasmin-web-panel/) · [Docker Hub](https://hub.docker.com/r/tarekaec/jasmin_web_panel) · [GitHub](https://github.com/101t/jasmin-web-panel)
- Isolated example: `docker run -d --name jasmin-web --network jasmin_default -p 127.0.0.1:8999:8000 -e DJANGO_SETTINGS_MODULE=config.settings.pro -e DEBUG=False -e SECRET_KEY='<long-random-secret>' -e PRODB_URL=postgres://jasmin:jasmin@db:5432/jasmin -e REDIS_HOST=redis -e TELNET_HOST=jasmin -e TELNET_PORT=8990 -e TELNET_USERNAME=jcliadmin -e TELNET_PW=jclipwd -v web_public:/app/public -v web_logs:/app/logs tarekaec/jasmin_web_panel:latest`
- Options: volumes `web_public:/app/public`, `web_logs:/app/logs`; web port `8000`; environment includes shared `DJANGO_SETTINGS_MODULE`, `DEBUG`, `REDIS_HOST`, `TELNET_HOST`, `TELNET_PORT`, `TELNET_USERNAME`, `TELNET_PW`, `SMPP_HOST`, `SMPP_PORT`, `HTTP_HOST`, `HTTP_PORT`, plus `SECRET_KEY`, `ALLOWED_HOSTS`, `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `PRODB_URL`, `REDIS_PORT`, `REDIS_DB`, and `SUBMIT_LOG`. `JASMIN_PANEL_DB_PASSWORD` and `JASMIN_PANEL_SECRET_KEY` can override development defaults. The panel needs PostgreSQL, Redis, and Jasmin. Change its initial administrator password.

## Jasmin panel worker (Celery)

Background worker for panel jobs. It runs the same panel image with its Celery entrypoint and has no published port.

- [Panel docs](https://about.supernovasoft.com/jasmin-web-panel/) · [Docker Hub](https://hub.docker.com/r/tarekaec/jasmin_web_panel) · [GitHub](https://github.com/101t/jasmin-web-panel)
- Compose-managed isolated example: `docker compose run --rm jasmin-celery`
- Options: same PostgreSQL, Redis, Jasmin, and secret-key settings as the web panel; `CELERY_LOG_LEVEL=info`; entrypoint `bash ./docker-entrypoint-celery.sh`.

## RabbitMQ

AMQP message broker required by Jasmin. It is internal to the Compose network and persists its broker state in `rabbitmq_data`.

- [Project](https://www.rabbitmq.com/) · [Docker Hub](https://hub.docker.com/_/rabbitmq) · [GitHub](https://github.com/rabbitmq/rabbitmq-server)
- Isolated example: `docker run -d --name rabbitmq --network jasmin_default -v rabbitmq_data:/var/lib/rabbitmq rabbitmq:management-alpine`
- Options: persistent volume `rabbitmq_data:/var/lib/rabbitmq`; AMQP port `5672` is internal and not published in this group.

## Redis

In-memory data store used by Jasmin and the web panel. Append-only persistence is enabled and stored in `redis_data`.

- [Project and docs](https://redis.io/docs/latest/) · [Docker Hub](https://hub.docker.com/_/redis) · [GitHub](https://github.com/redis/redis)
- Isolated example: `docker run -d --name redis --network jasmin_default -v redis_data:/data redis:alpine redis-server --appendonly yes`
- Options: persistent volume `redis_data:/data`; internal port `6379`; no host port is published.

## PostgreSQL (panel database)

PostgreSQL stores the web panel's users and configuration. It persists in `panel_db_data` and is internal to the Compose network.

- [Project and docs](https://www.postgresql.org/docs/) · [Docker Hub](https://hub.docker.com/_/postgres) · [GitHub](https://github.com/postgres/postgres)
- Isolated example: `docker run -d --name jasmin-web-db --network jasmin_default -e POSTGRES_DB=jasmin -e POSTGRES_USER=jasmin -e POSTGRES_PASSWORD=jasmin -v panel_db_data:/var/lib/postgresql/data postgres:latest`
- Options: volume `panel_db_data:/var/lib/postgresql/data`; `POSTGRES_DB=jasmin`, `POSTGRES_USER=jasmin`, `POSTGRES_PASSWORD` (override with `JASMIN_PANEL_DB_PASSWORD`); internal port `5432`.
