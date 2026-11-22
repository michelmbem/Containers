# Docker Compose container lab

This repository is a collection of independent Docker Compose groups for trying out databases, message brokers, identity services, developer tools, and observability systems on a local machine. Each top-level directory contains a Compose configuration and a `notes.md` with service descriptions, useful links, individual-container examples, ports, credentials, and persistence settings.

## Groups

| Area | Groups |
| --- | --- |
| Databases and data stores | [Db2](./db2/notes.md), [Firebird](./firebird/notes.md), [MariaDB](./mariadb/notes.md), [MongoDB](./mongodb/notes.md), [Microsoft SQL Server](./ms-sql-server/notes.md), [Oracle Database Free](./oracle-database/notes.md), [PostgreSQL](./postgresql/notes.md), [Redis](./redis/notes.md) |
| Messaging and streaming | [ActiveMQ](./activemq/notes.md), [Jasmin SMPP](./jasmin/notes.md), [Kafka](./kafka/notes.md), [RabbitMQ](./rabbitmq/notes.md) |
| Identity and directory services | [Keycloak](./keycloak/notes.md), [OpenLDAP](./openldap/notes.md) |
| Development and diagnostics | [MailDev](./maildev/notes.md), [SonarQube](./sonarqube/notes.md), [Zipkin](./zipkin/notes.md), [Elastic Stack](./elk/notes.md) |

Several groups include a web interface alongside the main service. Some database groups also include a one-shot service that initializes sample data when the database is ready.

## Run a group

Run Compose commands from the directory containing that group's `docker-compose.yml`:

```sh
cd postgresql
docker compose up -d
docker compose ps
docker compose logs -f
```

Stop the services while keeping their data with `docker compose stop`. Remove the containers and the group's default network with `docker compose down`; named volumes remain in place. To remove the volumes and their data as well, use `docker compose down -v`. To also remove images used by the group, use `docker compose down --rmi all`; combine both cleanup options with `docker compose down --rmi all -v`. Removing volumes permanently deletes their contents. See the [Docker Compose `down` reference](https://docs.docker.com/reference/cli/docker/compose/down/) for the cleanup options.

Some groups require environment variables or a local `.env` file. Check the group's `notes.md` and any `.env-template` before starting. For example, the Elastic Stack group requires copying `.env-template` to `.env` and setting passwords.

## Remarks

### Access the host from a container

Use `host.docker.internal` to reference the host from a container. Docker Desktop provides this hostname automatically. On Linux, if it does not resolve, map it to Docker's host gateway in the service configuration:

```yaml
extra_hosts:
  - "host.docker.internal:host-gateway"
```

The SonarQube group uses this mapping to reach PostgreSQL running on the host. See Docker's [Compose networking guide](https://docs.docker.com/compose/how-tos/networking/).

### Networking and ports

Services in the same Compose group can reach one another by service name on that group's default network (for example, `postgres:5432`). Use the published host address when connecting from a host application. Most published ports in this repository bind to `127.0.0.1` and are therefore intended for local access. PostgreSQL publishes port `5432` for host tools and the separate SonarQube group.

### Credentials and persistence

The groups are designed as local development examples. Where default credentials are configured, replace them before exposing services beyond the host. Named Docker volumes preserve database files, broker state, and application settings across container recreation; `docker compose down` does not remove them by default.
