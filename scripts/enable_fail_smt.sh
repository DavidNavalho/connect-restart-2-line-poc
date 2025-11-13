#!/usr/bin/env bash
set -euo pipefail

base_url=${CONNECT_URL:-http://localhost:8083}

echo "Enabling failure mode via converter mismatch (JsonConverter with schemas=true)."
for i in {1..5}; do
  name="sink-$i"
  topic="poc-topic-$i"
  resp=$(curl -s -w "\n%{http_code}" -X PUT \
    -H "Content-Type: application/json" \
    --data @- "$base_url/connectors/$name/config" <<JSON
{
  "name": "$name",
  "connector.class": "org.apache.kafka.connect.tools.MockSinkConnector",
  "tasks.max": "4",
  "topics": "$topic",
  "value.converter": "org.apache.kafka.connect.json.JsonConverter",
  "value.converter.schemas.enable": "true"
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

echo "Seeding a few non-JSON messages so sinks fail to deserialize..."
for i in {1..5}; do
  docker compose exec -T kafka bash -lc 'printf "hello\nworld\n" | kafka-console-producer --bootstrap-server kafka:9092 --topic poc-topic-'"$i"' >/dev/null'
done

echo "Done. Use: bash scripts/list_failed.sh"
