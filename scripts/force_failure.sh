#!/usr/bin/env bash
set -euo pipefail

base_url=${CONNECT_URL:-http://localhost:8083}

echo "Producing bad non-JSON records to trigger JsonConverter failures..."
bash "$(dirname "$0")/seed-bad.sh"

echo "Waiting up to 20s for failures to be reported..."
for i in {1..20}; do
  failed=$(curl -s "$base_url/connectors?expand=status" | jq -r 'to_entries[] | select(.value.status.connector.state=="FAILED" or (.value.status.tasks | map(.state=="FAILED") | any)) | .key' || true)
  if [[ -n "$failed" ]]; then
    echo "Failed connectors:"
    echo "$failed"
    exit 0
  fi
  sleep 1
done
echo "No failures detected yet. Try: bash scripts/list_failed.sh"
