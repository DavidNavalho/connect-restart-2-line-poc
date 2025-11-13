#!/usr/bin/env bash
set -euo pipefail

base_url=${CONNECT_URL:-http://localhost:8083}

echo "Connectors:"
curl -s "$base_url/connectors" | jq -r '.'

echo
echo "Statuses:"
names=$(curl -s "$base_url/connectors" | jq -r '.[]')
if [[ -z "${names}" ]]; then
  echo "(none)"
  exit 0
fi

for c in $names; do
  echo "--- $c status ---"
  curl -s "$base_url/connectors/$c/status" | jq -r '.'
done

echo
echo "Configs:"
for c in $names; do
  echo "--- $c config ---"
  curl -s "$base_url/connectors/$c/config" | jq -r '.'
done

