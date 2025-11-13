#!/usr/bin/env bash
set -euo pipefail

base_url=${CONNECT_URL:-http://localhost:8083}

for i in {1..5}; do
  name="sink-$i"
  topic="poc-topic-$i"
  echo "Registering connector: $name (MockSink, topic=$topic)"
  resp=$(curl -s -w "\n%{http_code}" -X PUT \
    -H "Content-Type: application/json" \
    --data @- "$base_url/connectors/$name/config" <<JSON
{
  "name": "$name",
  "connector.class": "org.apache.kafka.connect.tools.MockSinkConnector",
  "tasks.max": "4",
  "topics": "$topic",
  "value.converter": "org.apache.kafka.connect.json.JsonConverter",
  "value.converter.schemas.enable": "true",
  "consumer.override.group.id": "cg-sink-$i",
  "consumer.override.auto.offset.reset": "latest"
}
JSON
)
  body="$(echo "$resp" | sed '$d')"
  code="$(echo "$resp" | tail -n1)"
  echo "$name => HTTP $code"
  if [[ "$code" -ge 400 ]]; then
    echo "$body"
  fi
done

echo "Connector registrations submitted."
