#!/bin/sh
envsubst '${DB_NAME} ${DB_USER}' < /servers.json.template > /pgadmin4/servers.json
umask 077
printf 'postgres:5432:*:%s:%s\n' "$DB_USER" "$DB_PASSWORD" > /tmp/pgadmin.pgpass
export PGPASS_FILE=/tmp/pgadmin.pgpass
exec /entrypoint.sh
