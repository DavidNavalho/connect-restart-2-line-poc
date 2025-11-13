#!/usr/bin/env bash
set -euo pipefail

json_record='{"schema":{"type":"struct","fields":[{"type":"string","optional":true,"field":"msg"}],"optional":true,"name":"Msg"},"payload":{"msg":"ok"}}'

echo "Producing valid JSON-with-schema records to each topic."
for i in {1..5}; do
  docker compose exec -T kafka bash -lc "for j in \$(seq 1 3); do printf '%s\n' '$json_record' | kafka-console-producer --bootstrap-server kafka:9092 --topic poc-topic-$i >/dev/null; done"
done
echo "Done."

