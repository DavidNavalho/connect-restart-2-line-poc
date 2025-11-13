#!/usr/bin/env bash
set -euo pipefail

echo "Creating missing sink directories inside the Connect container..."
docker compose exec -T connect bash -lc 'mkdir -p /data/sink-{1..5} && ls -ld /data/sink-*'
echo "Directories created. You can now restart failed tasks."

