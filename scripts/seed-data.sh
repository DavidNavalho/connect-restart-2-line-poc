#!/usr/bin/env bash
set -euo pipefail

echo "Seeding a few messages into topics..."
for i in {1..5}; do
  echo "Seeding poc-topic-$i"
  docker compose exec -T kafka bash -lc 'seq 1 5 | kafka-console-producer --bootstrap-server kafka:9092 --topic poc-topic-'"$i"' >/dev/null'
done
echo "Done."

