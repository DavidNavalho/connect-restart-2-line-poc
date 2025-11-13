#!/usr/bin/env bash
set -euo pipefail

echo "Producing non-JSON lines to each topic (these will fail JsonConverter)."
for i in {1..5}; do
  docker compose exec -T kafka bash -lc 'printf "hello\nworld\n" | kafka-console-producer --bootstrap-server kafka:9092 --topic poc-topic-'"$i"' >/dev/null'
done
echo "Done."

