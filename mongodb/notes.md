# MongoDB document database and sample dataset

This group runs MongoDB, a one-shot importer for the Game of Thrones sample, and Mongo Express. Start the stack with `docker compose up -d`; stop and preserve data with `docker compose stop`, or remove containers with `docker compose down`. Add `-v` to delete MongoDB data and reset the import marker; add `--rmi all` to remove images (`docker compose down --rmi all -v` resets everything).

## MongoDB Community Server

MongoDB is a document database. It listens on `127.0.0.1:27017`; the admin login defaults to `admin` / `mongoadm`. The `mongodb_data` and `mongodb_config` Docker volumes persist database and configuration files.

- [Product and docs](https://www.mongodb.com/docs/) · [Docker Hub](https://hub.docker.com/r/mongodb/mongodb-community-server) · [GitHub](https://github.com/mongodb/mongo)
- Isolated example: `docker run -d --name mongodb -p 127.0.0.1:27017:27017 -e MONGODB_INITDB_ROOT_USERNAME=admin -e MONGODB_INITDB_ROOT_PASSWORD=mongoadm -v mongodb_data:/data/db -v mongodb_config:/data/configdb mongodb/mongodb-community-server:7.0-ubi8-slim`
- Options: persistent volumes `mongodb_data:/data/db`, `mongodb_config:/data/configdb`; port `27017`; `MONGODB_INITDB_ROOT_USERNAME`, `MONGODB_INITDB_ROOT_PASSWORD`. Root credentials are for local development; initialization variables do not reset an existing data volume.

## Game of Thrones sample importer (`install-got`, one-shot)

One-shot MongoDB client service that uses `mongosh` to load `got-characters.json` into `got.characters` after MongoDB is healthy. A marker prevents repeat imports after successful installation.

- [MongoDB tools and docs](https://www.mongodb.com/docs/) · [Docker Hub](https://hub.docker.com/r/mongodb/mongodb-community-server) · [GitHub](https://github.com/mongodb/mongo)
- Compose-managed example: `docker compose run --rm install-got`
- Options: read-only mounts `./install-got/install-got.sh:/installer/install-got.sh`, `./got-characters.json:/input/got-characters.json`; root credentials via `MONGO_INITDB_ROOT_USERNAME` and `MONGO_INITDB_ROOT_PASSWORD`; waits for a healthy MongoDB service. It is designed to run through Compose once.

## Mongo Express

Web-based MongoDB administration interface. Open it at `http://127.0.0.1:8081`; it connects to the `mongodb` service and uses basic authentication (`admin` / `mongoadm` by default).

- [Project](https://mongo-express.com/) · [Docker Hub](https://hub.docker.com/_/mongo-express) · [GitHub](https://github.com/mongo-express/mongo-express)
- Isolated example: `docker run -d --name mongo-express --network mongodb_default -p 127.0.0.1:8081:8081 -e ME_CONFIG_MONGODB_SERVER=mongodb -e ME_CONFIG_MONGODB_ADMINUSERNAME=admin -e ME_CONFIG_MONGODB_ADMINPASSWORD=mongoadm -e ME_CONFIG_BASICAUTH_USERNAME=admin -e ME_CONFIG_BASICAUTH_PASSWORD=mongoadm mongo-express:latest`
- Options: web port `8081`; `ME_CONFIG_MONGODB_SERVER`, `ME_CONFIG_MONGODB_ADMINUSERNAME`, `ME_CONFIG_MONGODB_ADMINPASSWORD`, `ME_CONFIG_BASICAUTH_USERNAME`, `ME_CONFIG_BASICAUTH_PASSWORD`. Requires MongoDB on the same network.
