#!/usr/bin/env bash
set -euo pipefail

here="$(cd -- "$(dirname -- "$0")" && pwd)"

echo "Starting/refreshing Docker stack..."
docker compose up -d

echo "Waiting for Kafka Connect to be ready..."
bash "$here/wait-for-connect.sh"

echo "Creating topics..."
bash "$here/create-topics.sh"

echo "Registering 5 connectors (4 tasks each)..."
bash "$here/register-connectors.sh"

echo "Forcing failures (produce bad records)..."
bash "$here/force_failure.sh"

echo
echo "Final status: failed connectors"
bash "$here/list_failed.sh"

echo
echo "Next steps:"
echo "1) Restart failed tasks using your 2-line script:"
echo "   bash $here/restart_failed.sh"
echo "2) Verify all tasks are RUNNING:"
echo "   bash $here/list_states.sh"

