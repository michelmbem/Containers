#!/usr/bin/env bash
set -Eeuo pipefail

MARKER=/state/roastery-installed

if [[ -f "$MARKER" ]]; then
  echo "ROASTERY sample database is already installed."
  exit 0
fi

su -p db2inst1 -c 'source /home/db2inst1/sqllib/db2profile && db2 connect to ROASTERY && db2 -stvf /scripts/01-roastery.sql && db2 connect reset'
touch "$MARKER"
echo "ROASTERY sample database installed."
