#!/usr/bin/env bash
set -Eeuo pipefail

sample=/samples/employee.fdb
destination="${FIREBIRD_DATA:-/var/lib/firebird/data}/employee.fdb"

if [[ ! -s "$sample" ]]; then
  echo "Firebird employee sample database is missing: $sample" >&2
  exit 1
fi

install -o firebird -g firebird -m 0660 "$sample" "$destination"
echo "Installed the Firebird employee sample database at $destination"
