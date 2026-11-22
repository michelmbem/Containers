#!/usr/bin/env bash
set -Eeuo pipefail

MARKER=/state/roastery-installed

if [[ -f "$MARKER" ]]; then
  echo "ROASTERY sample database is already installed."
  exit 0
fi

if [[ -z "${DB2INST1_PASSWORD:-}" ]]; then
  echo "DB2INST1_PASSWORD is required." >&2
  exit 1
fi

su -p db2inst1 -c 'bash /scripts/install-roastery-as-instance-user.sh'
touch "$MARKER"
echo "ROASTERY sample database installed."
