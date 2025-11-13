#!/usr/bin/env bash
set -euo pipefail

topics=(poc-topic-1 poc-topic-2 poc-topic-3 poc-topic-4 poc-topic-5)

for t in "${topics[@]}"; do
  echo "Creating topic: $t"
  docker compose exec -T kafka bash -lc "kafka-topics --bootstrap-server kafka:9092 --create --if-not-exists --topic $t --partitions 4 --replication-factor 1" || true
done
echo "Topics ready."

