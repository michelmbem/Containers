# Microsoft SQL Server sample database stack

This group runs SQL Server 2022 Developer, a one-shot volume permission fixer, a one-shot sample installer, and DbGate. Start with `docker compose up -d`, stop and retain database files with `docker compose stop`, or remove containers with `docker compose down`. Add `-v` to remove database and client state; add `--rmi all` to remove images (`docker compose down --rmi all -v` resets the group).

## SQL Server

Microsoft's relational database server. The listener is `127.0.0.1:1433`; the `sa` password defaults to `$qlDb@min`. The service stores database, log, and secret files in separate Docker-managed volumes. Before startup, `fix-volume-permissions` assigns those volumes to SQL Server's non-root UID (`10001:0`), which prevents `Access is denied` errors while SQL Server creates its system databases.

- [Product and Docker deployment docs](https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-docker-container-deployment?view=sql-server-ver16) · [Microsoft Container Registry](https://mcr.microsoft.com/en-us/product/mssql/server/about) · [GitHub](https://github.com/microsoft/mssql-docker)
- Isolated example: `docker run -d --name sql-server -p 127.0.0.1:1433:1433 -e ACCEPT_EULA=Y -e MSSQL_PID=Developer -e MSSQL_SA_PASSWORD='$qlDb@min' -v mssql_data:/var/opt/mssql/data -v mssql_log:/var/opt/mssql/log -v mssql_secrets:/var/opt/mssql/secrets mcr.microsoft.com/mssql/server:2022-latest`
- Options: volumes `mssql_data:/var/opt/mssql/data`, `mssql_log:/var/opt/mssql/log`, `mssql_secrets:/var/opt/mssql/secrets`; `ACCEPT_EULA`, `MSSQL_PID`, `MSSQL_SA_PASSWORD`; port `1433`. Set a strong password when changing the local default.

## Sample installer (`install-samples`, one-shot)

Waits for SQL Server to become healthy, then loads the included sample databases and the `CommunityGarden` example. A database marker prevents successful installation from running again.

- [SQL Server container deployment docs](https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-docker-container-deployment?view=sql-server-ver16) · [Container image](https://mcr.microsoft.com/en-us/product/mssql/server/about) · [GitHub](https://github.com/microsoft/mssql-docker)
- Compose-managed example: `docker compose run --rm install-samples`
- Options: read-only mounts for `install-samples.sh`, `samples/`, and `scripts/`; requires `ACCEPT_EULA` and `MSSQL_SA_PASSWORD`; depends on healthy `sql-server`. Run through Compose to retain the configured dependencies and mounts.

## DbGate

Web database client configured to connect to the `master` database on `sql-server`. Open it at `http://127.0.0.1:3101`.

- [Project and docs](https://dbgate.org/) · [Docker docs](https://docs.dbgate.io/installation/docker/) · [Docker Hub](https://hub.docker.com/r/dbgate/dbgate) · [GitHub](https://github.com/dbgate/dbgate)
- Isolated example: `docker run -d --name dbgate-mssql --network ms-sql-server_default -p 127.0.0.1:3101:3000 -e CONNECTIONS=mssql -e LABEL_mssql='SQL Server' -e SERVER_mssql=sql-server -e PORT_mssql=1433 -e DATABASE_mssql=master -e USER_mssql=sa -e PASSWORD_mssql='$qlDb@min' -e ENGINE_mssql=mssql@dbgate-plugin-mssql -v dbgate_mssql_data:/root/.dbgate dbgate/dbgate:latest`
- Options: settings volume `dbgate_mssql_data:/root/.dbgate`; web port `3000`; connection variables shown above. Requires SQL Server on the same Docker network.
