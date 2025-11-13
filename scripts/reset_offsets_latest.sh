#!/usr/bin/env bash
set -euo pipefail

base_url=${CONNECT_URL:-http://localhost:8083}

echo "Attempting to reset offsets for connectors (will rely on consumer.override.auto.offset.reset=latest)."
for i in {1..5}; do
  name="sink-$i"
  resp=$(curl -s -w "\n%{http_code}" -X DELETE "$base_url/connectors/$name/offsets") || true
  body="$(echo "$resp" | sed '$d')"
  code="$(echo "$resp" | tail -n1)"
  echo "$name => HTTP $code"
  if [[ "$code" -ge 400 ]]; then
    echo "$body"
  fi
done

echo "If the DELETE /offsets endpoint is unsupported (404/405), you can reset all offsets by deleting the offsets topic (PoC only):"
echo "  docker compose exec -T kafka kafka-topics --bootstrap-server kafka:9092 --delete --topic connect-offsets"
echo "Connect will recreate it automatically."

