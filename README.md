# What's this repo for?

"We should do AI" is getting out of hand. It was recently suggested that we could use an LLM to "self-heal" failed Kafka Connectors. Obviously I answered I could write a bash script that did that in two lines. It's not pretty, but it's two lines!

Of course, I then did use an LLM for something it's good at: building a quick PoC to prove my 2-line script works! Everything here except this first paragraph and the script, where LLM-generated.

# Kafka Connect Failed Task Restart PoC

This proof-of-concept spins up Kafka + Kafka Connect, creates 5 connectors (each with max 4 tasks), intentionally fails them, and demonstrates recovering them with a 2-line restart script.

> Note: unfortunately, the Mock Sink Connector only instantiates a single task - despite the max being set to 4 - but this doesn't limit the PoC in any way!

## Prerequisites

- Docker and Docker Compose v2 (`docker compose`)
- `curl`
- `jq`

# Quick run
1) Run the PoC: `bash scripts/poc_until_failed.sh`
2) Run the two-line script: `bash scripts/restart_failed.sh`
3) Check connector states: `bash scripts/list_states.sh`

# More details...

## Start the stack

1) `docker compose up -d`
2) `bash scripts/wait-for-connect.sh`

Quick setup to failed state (one command):

- `bash scripts/poc_until_failed.sh`

This brings the environment up, creates topics, registers connectors, injects failing records, and prints the failed connectors. Then run your 2-line script and verify states.

## Prepare topics (4 partitions each)

`bash scripts/create-topics.sh`

## Register 5 sink connectors (4 tasks each)

`bash scripts/register-connectors.sh`

These are `MockSinkConnector` instances, each consuming from one topic, configured with JsonConverter (schemas=true) and explicit consumer groups.

## See failed connectors

`bash scripts/list_failed.sh`

Expected: after forcing failures, the 5 connectors show failed state.

Force failures (bad records for JsonConverter):

- `bash scripts/force_failure.sh`
- `bash scripts/list_failed.sh`

## Fix the failure condition

Reset offsets to skip bad records, then restart:

`bash scripts/reset_offsets_groups.sh`

## Restart only failed connectors/tasks (2-line script)

This is exactly your script in two lines. Run it as-is:

`bash scripts/restart_failed.sh`

Script content:

```
failed=$(curl -s http://localhost:8083/connectors?expand=status | jq -r 'to_entries[] | select(.value.status.connector.state=="FAILED" or (.value.status.tasks | map(.state=="FAILED") | any)) | .key')
for c in $failed; do curl -s -X POST "http://localhost:8083/connectors/$c/restart?includeTasks=true&onlyFailed=true"; done
```

## Verify recovery

Run again:

`bash scripts/list_failed.sh`

Expected: "No failed connectors found." You can also inspect individual statuses, for example:

`curl -s http://localhost:8083/connectors/sink-1/status | jq` 

For a concise overview of all connectors and their task states:

`bash scripts/list_states.sh`

Optional helpers:
- `bash scripts/seed-data.sh` to produce additional data to the topics

## Cleanup

`docker compose down -v`

## Notes

- The Connect container runs as root in this PoC to avoid file permission issues with the mounted `./data` volume.
- The stack uses Confluent Platform images; workload is light (single-broker, single-worker, small topics/files).
- `CONNECT_URL` env var can override the default `http://localhost:8083` in scripts where applicable.
