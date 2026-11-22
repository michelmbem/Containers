#!/usr/bin/env bash
set -euo pipefail

mongo_args=(
  --host mongodb
  --port 27017
  --username "$MONGO_INITDB_ROOT_USERNAME"
  --password "$MONGO_INITDB_ROOT_PASSWORD"
  --authenticationDatabase admin
)

if mongosh --quiet "${mongo_args[@]}" --eval 'quit(db.getSiblingDB("got")._install_state.findOne({_id: "got-characters-v1"}) ? 0 : 1)'; then
  echo 'The got characters collection has already been installed; skipping.'
  exit 0
fi

mongoimport \
  "${mongo_args[@]}" \
  --db got \
  --collection characters \
  --jsonArray \
  --file /input/got-characters.json

mongosh --quiet "${mongo_args[@]}" --eval '
  db.getSiblingDB("got")._install_state.updateOne(
    { _id: "got-characters-v1" },
    { $setOnInsert: { installedAt: new Date(), source: "got-characters.json" } },
    { upsert: true }
  );
'

echo 'The got database and characters collection are ready.'
