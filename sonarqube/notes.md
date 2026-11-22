# SonarQube code quality analysis

This group runs SonarQube Community Build as a single web application. It requires the PostgreSQL database configured in this Compose file to be running on the host. Start with `docker compose up -d`, stop while retaining data with `docker compose stop`, or remove the container with `docker compose down`. Add `-v` to delete SonarQube data and logs; add `--rmi all` to remove its image (`docker compose down --rmi all -v` resets the group).

## SonarQube Community Build

SonarQube inspects code and reports bugs, vulnerabilities, and maintainability issues. Open the web UI at `http://127.0.0.1:9000`. Data and logs use Docker volumes; plugins are mounted from `extensions/`.

- [Product and docs](https://docs.sonarsource.com/sonarqube-server/) · [Docker Hub](https://hub.docker.com/_/sonarqube) · [GitHub](https://github.com/SonarSource/sonarqube)
- Isolated example: `docker run -d --name sonarqube -p 127.0.0.1:9000:9000 --add-host host.docker.internal:host-gateway -e SONAR_JDBC_URL=jdbc:postgresql://host.docker.internal:5432/sonar -e SONAR_JDBC_USERNAME=sonar -e SONAR_JDBC_PASSWORD=sonar -v sonar_data:/opt/sonarqube/data -v sonar_logs:/opt/sonarqube/logs -v "$PWD/extensions:/opt/sonarqube/extensions" sonarqube:community`
- Options: volumes `sonar_data:/opt/sonarqube/data`, `sonar_logs:/opt/sonarqube/logs`, and read/write plugin mount `./extensions:/opt/sonarqube/extensions`; web port `9000`; `SONAR_JDBC_URL`, `SONAR_JDBC_USERNAME`, `SONAR_JDBC_PASSWORD`. PostgreSQL role/database must already exist and be reachable from the container.
