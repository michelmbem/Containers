# Firebird relational database

This group runs Firebird with the official Firebird 5 `employee.fdb` sample and the DbGate web client. Start with `docker compose up -d`; on the first start, Firebird installs the sample into its data volume before serving connections. Stop while retaining state with `docker compose stop`, or remove containers with `docker compose down`. Add `-v` to delete the database and client settings; add `--rmi all` to remove images (`docker compose down --rmi all -v` resets everything).

The initializer runs only with an empty Firebird data directory. If you previously started this group with the `field-notes.fdb` database, use `docker compose down -v` to clear the old data volume before starting the updated stack.

## Firebird

Firebird is a compact relational database server. It installs the version-matched `employee.fdb` in `firebird_data` on first startup. The sample binary was extracted from the official Firebird 5.0.4 Windows x64 distribution and is compatible with the Firebird 5.0.4 server image. The listener is published at `127.0.0.1:3050`.

- [Project and documentation](https://firebirdsql.org/en/documentation/) · [Firebird 5.0.4 release and sample source](https://github.com/FirebirdSQL/firebird/releases/tag/v5.0.4) · [Docker image docs](https://github.com/FirebirdSQL/firebird-docker) · [Docker Hub](https://hub.docker.com/r/firebirdsql/firebird) · [GitHub](https://github.com/FirebirdSQL/firebird)
- Downloaded `employee.fdb` SHA-256: `1d86ba1aaa76fff29d03711f27139cb915b606b3d927a1be85505fd3db17e2e8`.
- Isolated example: `docker run -d --name firebird -p 127.0.0.1:3050:3050 -e FIREBIRD_ROOT_PASSWORD='FirebirdAdm1n!' -e FIREBIRD_DATABASE=employee.fdb -e FIREBIRD_DATABASE_DEFAULT_CHARSET=UTF8 -v firebird_data:/var/lib/firebird/data -v "$PWD/scripts:/docker-entrypoint-initdb.d:ro" -v "$PWD/samples/employee.fdb:/samples/employee.fdb:ro" firebirdsql/firebird:5.0.4`
- Options: persistent database volume `firebird_data:/var/lib/firebird/data`; read-only initialization scripts and sample mounts; `FIREBIRD_ROOT_PASSWORD`, `FIREBIRD_DATABASE`, `FIREBIRD_DATABASE_DEFAULT_CHARSET`; port `3050`. The official entrypoint runs initialization files only when the data directory is empty.

## DbGate

DbGate is a web client for managing databases. It is preconfigured for this Firebird database and is available at `http://127.0.0.1:3102`.

- [Project and docs](https://dbgate.org/) · [Docker docs](https://docs.dbgate.io/installation/docker/) · [Docker Hub](https://hub.docker.com/r/dbgate/dbgate) · [GitHub](https://github.com/dbgate/dbgate)
- Isolated example: `docker run -d --name dbgate-firebird --network firebird_default -p 127.0.0.1:3102:3000 -e CONNECTIONS=firebird -e SERVER_firebird=firebird -e PORT_firebird=3050 -e DATABASE_firebird=/var/lib/firebird/data/employee.fdb -e USER_firebird=SYSDBA -e PASSWORD_firebird='FirebirdAdm1n!' -e ENGINE_firebird=firebird@dbgate-plugin-firebird -v dbgate_firebird_data:/root/.dbgate dbgate/dbgate:latest`
- Options: settings volume `dbgate_firebird_data:/root/.dbgate`; port `3000`; connection variables `CONNECTIONS`, `SERVER_firebird`, `PORT_firebird`, `DATABASE_firebird`, `USER_firebird`, `PASSWORD_firebird`, `ENGINE_firebird`. Requires Firebird on the same Docker network.
