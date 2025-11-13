#!/usr/bin/env bash
set -euo pipefail

base_url=${CONNECT_URL:-http://localhost:8083}

echo "Disabling Fail SMT and restoring base configs."
for i in {1..5}; do
  name="sink-$i"
  topic="poc-topic-$i"
  code=$(curl -s -o /dev/null -w "%{http_code}\n" -X PUT \
    -H "Content-Type: application/json" \
    --data @- "$base_url/connectors/$name/config" <<JSON
{
  "name": "$name",
  "connector.class": "org.apache.kafka.connect.tools.MockSinkConnector",
  "tasks.max": "4",
  "topics": "$topic"
}
JSON
)
  echo "$name => HTTP $code"
done

echo "Now restart failed tasks using your 2-line script: bash scripts/restart_failed.sh"
