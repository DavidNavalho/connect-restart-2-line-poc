#!/usr/bin/env bash
set -euo pipefail

echo "Resetting consumer group offsets to latest for sink connectors..."
for i in {1..5}; do
  group="cg-sink-$i"
  topic="poc-topic-$i"
  echo "Group $group -> topic $topic : to-latest"
  docker compose exec -T kafka bash -lc "kafka-consumer-groups --bootstrap-server kafka:9092 --group $group --reset-offsets --to-latest --topic $topic --execute" || true
done
echo "Done. Now run: bash scripts/restart_failed.sh"

