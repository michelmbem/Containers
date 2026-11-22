#!/bin/sh
envsubst '${DB_NAME} ${DB_USER}' < /servers.json.template > /pgadmin4/servers.json
exec /entrypoint.sh
