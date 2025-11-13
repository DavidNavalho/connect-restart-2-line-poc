#!/usr/bin/env bash
set -euo pipefail

base_url=${CONNECT_URL:-http://localhost:8083}

resp=$(curl -s "$base_url/connectors?expand=status") || {
  echo "Failed to fetch connector statuses from $base_url" >&2
  exit 1
}

if [[ "$(echo "$resp" | jq 'keys | length')" -eq 0 ]]; then
  echo "No connectors found."
  exit 0
fi

echo "All connector states:"
echo "$resp" | jq -r '
  to_entries
  | sort_by(.key)
  | .[]
  | .key as $name
  | $name
    + ": connector=" + .value.status.connector.state
    + ", tasks=["
    + ( .value.status.tasks | sort_by(.id) | map("\(.id):\(.state)") | join(",") )
    + "]"
'

# Show brief details for any non-RUNNING tasks
issues=$(echo "$resp" | jq -r '
  to_entries
  | sort_by(.key)
  | map({name: .key, tasks: .value.status.tasks})
  | map({name, issues: (.tasks | map(select(.state != "RUNNING")))})
  | map(select(.issues | length > 0))
  | if length == 0 then [] else . end
')

if [[ "$(echo "$issues" | jq 'length')" -gt 0 ]]; then
  echo
  echo "Non-RUNNING task details:"
  echo "$issues" | jq -r '
    .[]
    | ("- " + .name + " failures:"),
      ( .issues[]
        | "  task " + (.id|tostring) + " = " + .state
          + ( if .worker_id then " (worker=" + .worker_id + ")" else "" end )
          + ( if .trace then " - " + ((.trace | split("\n")[0])) else "" end )
      )
  '
fi
