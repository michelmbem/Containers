# Oracle Database Free with example schemas

This group runs Oracle Database Free, a one-shot installer for Oracle's sample schemas, and DbGate. Start with `docker compose up -d`, stop while preserving the database with `docker compose stop`, or remove containers with `docker compose down`. Add `-v` to delete database data, DbGate settings, and the sample-install marker; add `--rmi all` to remove images (`docker compose down --rmi all -v` resets the group).

## Oracle Database Free

Oracle's free developer database edition. It listens on `127.0.0.1:1521` and uses service `FREEPDB1`; initialization scripts in `scripts/` run at startup. Database and backup data persist in Docker volumes. The default DBA password is `oradmin` (`ORACLE_PWD`).

- [Product and container docs](https://www.oracle.com/database/free/) · [Oracle Container Registry image page](https://container-registry.oracle.com/ords/f?p=113:4:0::NO:RP,4:P4_REPOSITORY,AI_REPOSITORY:1863,1863) · [GitHub](https://github.com/oracle/docker-images/tree/main/OracleDatabase/SingleInstance)
- Isolated example: `docker run -d --name oracle-free -p 127.0.0.1:1521:1521 -e ORACLE_PWD=oradmin -e FIELD_NOTES_PASSWORD=FieldNotes1 -v oracle_data:/opt/oracle/oradata -v oracle_backup:/opt/oracle/backup -v "$PWD/scripts:/opt/oracle/scripts/startup:ro" container-registry.oracle.com/database/free:latest`
- Options: named volumes `oracle_data:/opt/oracle/oradata`, `oracle_backup:/opt/oracle/backup`; read-only startup scripts mount; `ORACLE_PWD`, `FIELD_NOTES_PASSWORD`; listener port `1521`. Oracle Registry may require account access and acceptance of license terms.

## Sample schema installer (`install-samples`, one-shot)

Builds a small installer image that extracts Oracle's sample schema archive and installs HR, CO, and SH into `FREEPDB1` once Oracle is healthy. A named volume stores the completion marker.

- [Sample schemas project](https://github.com/oracle/db-sample-schemas) · [Installer base image](https://container-registry.oracle.com/ords/f?p=113:4:0::NO:RP,4:P4_REPOSITORY,AI_REPOSITORY:1863,1863) · [GitHub](https://github.com/oracle/db-sample-schemas)
- Compose-managed example: `docker compose run --rm install-samples`
- Options: built locally from `install-samples/`; read-only archive mount `db-sample-schemas-23.3.zip`; `ORACLE_HOST`, `ORACLE_PORT`, `ORACLE_SERVICE`, `ORACLE_USER`, `ORACLE_PASSWORD`, `SAMPLE_SCHEMA_PASSWORD`, `DEFAULT_TABLESPACE`; marker volume `sample_install_state`. Use Compose so it waits for Oracle health and preserves one-time state.

## DbGate

Web-based database client configured for the `FIELD_NOTES` demonstration schema. Open it at `http://127.0.0.1:3100`.

- [Project and docs](https://dbgate.org/) · [Docker docs](https://docs.dbgate.io/installation/docker/) · [Docker Hub](https://hub.docker.com/r/dbgate/dbgate) · [GitHub](https://github.com/dbgate/dbgate)
- Isolated example: `docker run -d --name dbgate-oracle --network oracle-database_default -p 127.0.0.1:3100:3000 -e CONNECTIONS=oracle -e LABEL_oracle='Oracle Database Free' -e SERVER_oracle=oracle-free -e PORT_oracle=1521 -e USER_oracle=FIELD_NOTES -e PASSWORD_oracle=FieldNotes1 -e ENGINE_oracle=oracle@dbgate-plugin-oracle -e NODE_OPTIONS=--openssl-legacy-provider -v dbgate_data:/root/.dbgate dbgate/dbgate:latest`
- Options: settings volume `dbgate_data:/root/.dbgate`; web port `3000`; only the configured Oracle user and password are environment-driven in Compose. Requires Oracle on the same Docker network.
