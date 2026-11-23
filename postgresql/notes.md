# PostgreSQL database with pgAdmin

This group runs PostgreSQL and pgAdmin, with a sample database initialized from `scripts/`. Start with `docker compose up -d`, stop and retain state with `docker compose stop`, or remove containers with `docker compose down`. Add `-v` to remove database and pgAdmin state; add `--rmi all` to remove images (`docker compose down --rmi all -v` resets the group).

## PostgreSQL

PostgreSQL is an open-source relational database. The Compose configuration initializes database `pagila` with user `postgres` by default, and stores data in `postgres_data`. Port `5432` is published for local clients and for the separate SonarQube Compose group.

- [Project and docs](https://www.postgresql.org/docs/) · [Docker Hub](https://hub.docker.com/_/postgres) · [GitHub](https://github.com/postgres/postgres)
- Isolated example: `docker run -d --name postgres -p 5432:5432 -e POSTGRES_DB=pagila -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=sqladm -v postgres_data:/var/lib/postgresql -v "$PWD/scripts:/docker-entrypoint-initdb.d:ro" postgres:latest`
- Options: persistent volume `postgres_data:/var/lib/postgresql`; read-only initialization scripts mount; `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`; host port `5432` (published for host clients and the SonarQube group). PostgreSQL 18+ stores the cluster in a version-specific subdirectory of `/var/lib/postgresql`; initialization scripts run only for a new data volume.

## pgAdmin

pgAdmin is a web administration and query interface for PostgreSQL. Open `http://127.0.0.1:5050`; default login is `admin@local.org` / `admin`. The `BookStore PostgreSQL` server is preloaded and its password file is generated inside the container from the same `DB_USER` and `DB_PASSWORD` settings used by PostgreSQL, with a wildcard database field so the credentials work for every database on this server (including `chinook`). Server definitions are refreshed on each start.

- [Project and docs](https://www.pgadmin.org/docs/) · [Base Docker image](https://hub.docker.com/r/dpage/pgadmin4) · [GitHub](https://github.com/pgadmin-org/pgadmin4)
- Isolated example: build the group's custom image with `docker build -t local-pgadmin ./pgadmin`, then run `docker run -d --name pgadmin --network postgresql_default -p 127.0.0.1:5050:80 -e PGADMIN_DEFAULT_EMAIL=admin@local.org -e PGADMIN_DEFAULT_PASSWORD=admin -e DB_NAME=pagila -e DB_USER=postgres -e DB_PASSWORD=sqladm -v pgadmin_data:/var/lib/pgadmin local-pgadmin`
- Options: persistent volume `pgadmin_data:/var/lib/pgadmin`; port `80`; `PGADMIN_DEFAULT_EMAIL`, `PGADMIN_DEFAULT_PASSWORD`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`; `PGADMIN_REPLACE_SERVERS_ON_STARTUP`. Requires PostgreSQL on the same network. The example password is for local development.
