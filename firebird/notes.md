# Firebird relational database

This group runs Firebird with the official Firebird 5 `employee.fdb` sample and the CloudBeaver Community web client. Start with `docker compose up -d`; on the first start, Firebird installs the sample into its data volume before serving connections. Stop while retaining state with `docker compose stop`, or remove containers with `docker compose down`. Add `-v` to delete the database and client settings; add `--rmi all` to remove images (`docker compose down --rmi all -v` resets everything).

The initializer runs only with an empty Firebird data directory. If you previously started this group with the `field-notes.fdb` database, use `docker compose down -v` to clear the old data volume before starting the updated stack.

## Firebird

Firebird is a compact relational database server. It installs the version-matched `employee.fdb` in `firebird_data` on first startup. The sample binary was extracted from the official Firebird 5.0.4 Windows x64 distribution and is compatible with the Firebird 5.0.4 server image. The listener is published at `127.0.0.1:3050`.

- [Project and documentation](https://firebirdsql.org/en/documentation/) · [Firebird 5.0.4 release and sample source](https://github.com/FirebirdSQL/firebird/releases/tag/v5.0.4) · [Docker image docs](https://github.com/FirebirdSQL/firebird-docker) · [Docker Hub](https://hub.docker.com/r/firebirdsql/firebird) · [GitHub](https://github.com/FirebirdSQL/firebird)
- Downloaded `employee.fdb` SHA-256: `1d86ba1aaa76fff29d03711f27139cb915b606b3d927a1be85505fd3db17e2e8`.
- Isolated example: `docker run -d --name firebird -p 127.0.0.1:3050:3050 -e FIREBIRD_ROOT_PASSWORD='FirebirdAdm1n!' -e FIREBIRD_DATABASE=employee.fdb -e FIREBIRD_DATABASE_DEFAULT_CHARSET=UTF8 -v firebird_data:/var/lib/firebird/data -v "$PWD/scripts:/docker-entrypoint-initdb.d:ro" -v "$PWD/samples/employee.fdb:/samples/employee.fdb:ro" firebirdsql/firebird:5.0.4`
- Options: persistent database volume `firebird_data:/var/lib/firebird/data`; read-only initialization scripts and sample mounts; `FIREBIRD_ROOT_PASSWORD`, `FIREBIRD_DATABASE`, `FIREBIRD_DATABASE_DEFAULT_CHARSET`; port `3050`. The official entrypoint runs initialization files only when the data directory is empty.

## CloudBeaver Community

CloudBeaver is a web database client using DBeaver's JDBC drivers. It is available at `http://127.0.0.1:3102`. On first launch, complete the administrator setup. A preconfigured `Firebird Employee` connection points to the Firebird service; enter `SYSDBA` and the `FIREBIRD_ROOT_PASSWORD` value when connecting.

- [CloudBeaver docs](https://dbeaver.com/docs/cloudbeaver/) · [Docker image](https://hub.docker.com/r/dbeaver/cloudbeaver) · [Supported databases](https://dbeaver.com/docs/cloudbeaver/Supported-databases/)
- Workspace volume: `cloudbeaver_firebird_data:/opt/cloudbeaver/workspace`; datasource definition: `cloudbeaver/data-sources.json`; host port `3102` maps to CloudBeaver port `8978`. The Firebird Jaybird driver is included. Credentials are requested at connection time and are not stored in the datasource file.
