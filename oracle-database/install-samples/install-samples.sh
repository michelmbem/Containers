#!/usr/bin/env bash
set -euo pipefail

marker=/var/lib/install-samples/installed
if [[ -f "$marker" ]]; then
  echo 'Oracle sample schemas have already been installed; skipping.'
  exit 0
fi

archive=/input/db-sample-schemas-23.3.zip
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

unzip -q "$archive" -d "$work_dir"
sample_root="$work_dir/db-sample-schemas-23.3"

install_schema() {
  local schema_dir="$1"
  local install_script="$2"

  echo "Installing $(basename "$schema_dir") sample schema..."
  printf '%s\n' "$SAMPLE_SCHEMA_PASSWORD" "$DEFAULT_TABLESPACE" YES |
    sql -S -L \
      "${ORACLE_USER}/${ORACLE_PASSWORD}@//${ORACLE_HOST}:${ORACLE_PORT}/${ORACLE_SERVICE}" \
      "@${sample_root}/${schema_dir}/${install_script}"
}

install_schema human_resources hr_install.sql
install_schema customer_orders co_install.sql
install_schema sales_history sh_install.sql

mkdir -p "$(dirname "$marker")"
touch "$marker"
echo 'Oracle sample schemas installed successfully.'
