# Keycloak identity and access management

This group contains Keycloak with a development-mode server and a root-level `spi` directory for custom provider JARs. Start with `docker compose up -d`, stop while retaining data with `docker compose stop`, or remove containers with `docker compose down`. Add `-v` to delete Keycloak data; add `--rmi all` to remove the image as well (`docker compose down --rmi all -v` resets the group).

## Keycloak

Keycloak provides identity, authentication, and access management for applications. Open the admin console at `http://127.0.0.1:8181`; the initial development credentials are `admin` / `admin`.

- [Project and docs](https://www.keycloak.org/documentation) · [Docker image](https://quay.io/repository/keycloak/keycloak) · [GitHub](https://github.com/keycloak/keycloak)
- Isolated example: `docker run -d --name keycloak -p 127.0.0.1:8181:8080 -e KC_BOOTSTRAP_ADMIN_USERNAME=admin -e KC_BOOTSTRAP_ADMIN_PASSWORD=admin -v keycloak_data:/opt/keycloak/data -v "$PWD/spi:/opt/keycloak/providers:ro" quay.io/keycloak/keycloak:latest start-dev`
- Options: persistent volume `keycloak_data:/opt/keycloak/data`; read-only provider bind mount `./spi:/opt/keycloak/providers`; host port `8181`; bootstrap variables `KC_BOOTSTRAP_ADMIN_USERNAME`, `KC_BOOTSTRAP_ADMIN_PASSWORD`. `start-dev` is intended for development only.
