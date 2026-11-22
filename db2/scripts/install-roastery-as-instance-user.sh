#!/usr/bin/env bash
set -Eeuo pipefail

source /home/db2inst1/sqllib/db2profile

if ! db2 list node directory | grep -q 'ROASTERY_NODE'; then
  db2 catalog tcpip node ROASTERY_NODE remote db2 server 50000 >/dev/null
fi
if ! db2 list database directory | grep -q 'REMOTE_ROASTERY'; then
  db2 catalog database ROASTERY as REMOTE_ROASTERY at node ROASTERY_NODE >/dev/null
fi
db2 terminate >/dev/null

db2 connect to REMOTE_ROASTERY user db2inst1 using "$DB2INST1_PASSWORD"
db2 -tvf /scripts/01-roastery.sql
db2 connect reset
db2 terminate
