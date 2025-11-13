#!/usr/bin/env bash
set -euo pipefail

base_url=${CONNECT_URL:-http://localhost:8083}

echo "Checking for failed connectors/tasks..."
resp=$(curl -s "$base_url/connectors?expand=status")

names=$(echo "$resp" | jq -r 'to_entries[] | select(.value.status.connector.state=="FAILED" or (.value.status.tasks | map(.state=="FAILED") | any)) | .key')

if [[ -z "${names}" ]]; then
  echo "No failed connectors found."
  exit 0
fi

echo "Failed connectors:"
echo "$names"

echo
echo "Details:"
echo "$resp" | jq -r '
  to_entries
  | map(select(.value.status.connector.state=="FAILED" or (.value.status.tasks | map(.state=="FAILED") | any)))
  | .[]
  | "\(.key): connector=\(.value.status.connector.state), tasks=" + ([.value.status.tasks[].state] | join(","))
'

