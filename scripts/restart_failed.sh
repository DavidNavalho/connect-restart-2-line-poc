failed=$(curl -s http://localhost:8083/connectors?expand=status | jq -r 'to_entries[] | select(.value.status.connector.state=="FAILED" or (.value.status.tasks | map(.state=="FAILED") | any)) | .key')
for c in $failed; do curl -s -X POST "http://localhost:8083/connectors/$c/restart?includeTasks=true&onlyFailed=true"; done
