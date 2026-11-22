# MariaDB relational database

This group runs a MariaDB server and phpMyAdmin web client. Start with `docker compose up -d`, stop while retaining data with `docker compose stop`, or remove containers with `docker compose down`. Add `-v` to delete database data; add `--rmi all` to remove images (`docker compose down --rmi all -v` resets the group).

## MariaDB

MariaDB is a community-developed relational database server compatible with MySQL. Its database files persist in `mariadb_data`; the server listens on `127.0.0.1:3306`.

- [Project and docs](https://mariadb.org/documentation/) · [Docker Hub](https://hub.docker.com/_/mariadb) · [GitHub](https://github.com/MariaDB/server)
- Isolated example: `docker run -d --name mariadb -p 127.0.0.1:3306:3306 -e MARIADB_ROOT_PASSWORD=sqladm -v mariadb_data:/var/lib/mysql -v "$PWD/scripts:/docker-entrypoint-initdb.d:ro" mariadb:latest`
- Options: persistent volume `mariadb_data:/var/lib/mysql`; read-only initialization scripts `./scripts:/docker-entrypoint-initdb.d`; port `3306`; `MARIADB_ROOT_PASSWORD` (default `sqladm`). Initialization scripts execute only for a new data directory.

## phpMyAdmin

Browser-based administration tool for MySQL-compatible databases. This instance is preconfigured to connect to the MariaDB service as `root`; open `http://127.0.0.1:8000`.

- [Project and docs](https://www.phpmyadmin.net/docs/) · [Docker Hub](https://hub.docker.com/r/phpmyadmin/phpmyadmin) · [GitHub](https://github.com/phpmyadmin/phpmyadmin)
- Isolated example: `docker run -d --name phpmyadmin --network mariadb_default -p 127.0.0.1:8000:80 -e PMA_HOST=mariadb -e PMA_PORT=3306 -e PMA_USER=root -e PMA_PASSWORD=sqladm phpmyadmin:latest`
- Options: web port `80`; `PMA_HOST`, `PMA_PORT`, `PMA_USER`, `PMA_PASSWORD`. Requires MariaDB on the same Docker network; credential must match `MARIADB_ROOT_PASSWORD`.
