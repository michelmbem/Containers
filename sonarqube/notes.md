# SonarQube code quality analysis

This group runs SonarQube Community Build with a dedicated PostgreSQL 17 service. The database is isolated from the global PostgreSQL group and is reachable to SonarQube through the Compose service name `db`. It starts empty; existing SonarQube data in the global PostgreSQL group is not migrated or deleted. Start with `docker compose up -d`, stop while retaining data with `docker compose stop`, or remove containers with `docker compose down`. Add `-v` to delete the SonarQube database, application data, and logs; add `--rmi all` to remove images (`docker compose down --rmi all -v` resets the group).

## SonarQube Community Build

SonarQube inspects code and reports bugs, vulnerabilities, and maintainability issues. Open the web UI at `http://127.0.0.1:9000`. Application data and logs use Docker volumes; plugins are mounted from `extensions/`.

- [Product and docs](https://docs.sonarsource.com/sonarqube-server/) · [Docker Hub](https://hub.docker.com/_/sonarqube) · [GitHub](https://github.com/SonarSource/sonarqube)
- Isolated example: use `docker compose up -d` to start the bundled `postgres:17` database and SonarQube together; the JDBC URL is `jdbc:postgresql://db:5432/sonar`.
- Options: PostgreSQL persists in `sonar_postgres_data`; SonarQube uses `sonar_data:/opt/sonarqube/data`, `sonar_logs:/opt/sonarqube/logs`, and the read/write plugin mount `./extensions:/opt/sonarqube/extensions`. The database and role are initialized as `sonar`; set `SONAR_DB_PASSWORD` in a local `.env` to override the development default. The database container is private to this Compose network and does not publish host port `5432`.
