#!/usr/bin/env bash
set -euo pipefail

echo "Waiting for Kafka Connect on http://localhost:8083 ..."
for i in {1..90}; do
  if curl -sf http://localhost:8083/connectors >/dev/null; then
    echo "Kafka Connect is up."
    exit 0
  fi
  sleep 1
done
echo "Timed out waiting for Kafka Connect." >&2
exit 1

