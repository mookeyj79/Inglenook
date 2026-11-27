#!/usr/bin/env bash
# Insomnia's part of the app scene: a few saved requests in the local Scratch Pad, one
# of them open with a JSON body and a saved JSON response, so the request and response
# editors, the method labels and the status tag all show. Fixed content, never live: no
# request is sent, and nothing here sets a color. The port's theme decides every color.
# The recipe's stage runs it before launch: bash "$INGLENOOK_SCENE/insomnia/seed.sh"
set -euo pipefail
cfg=${XDG_CONFIG_HOME:-$HOME/.config}/Insomnia
mkdir -p "$cfg/responses"
# An hour ago, so the response says "1 Hour Ago" whatever the day.
t=$(( ($(date +%s) - 3600) * 1000 ))
wrk=wrk_scratchpad

# One request per method, newest last, so the sidebar lists them in this order.
req() { # id method name url sortkey body-mime body-text
  local body='{}'
  if [ -n "$6" ]; then body=$(printf '{"mimeType":"%s","text":%s}' "$6" "$7"); fi
  printf '{"_id":"%s","type":"Request","parentId":"%s","modified":%s,"created":%s,"url":"%s","name":"%s","description":"","method":"%s","body":%s,"parameters":[],"headers":[{"name":"Content-Type","value":"application/json"}],"authentication":{},"metaSortKey":%s,"isPrivate":false,"settingStoreCookies":true,"settingSendCookies":true,"settingDisableRenderRequestBody":false,"settingEncodeUrl":true,"settingRebuildPath":true,"settingFollowRedirects":"global"}\n' \
    "$1" "$wrk" "$t" "$t" "$4" "$3" "$2" "$body" "$5"
}
body='"{\n  \"title\": \"Wood for the stove\",\n  \"quantity\": 12,\n  \"split\": true,\n  \"delivered\": null,\n  \"tags\": [\"oak\", \"ash\"]\n}"'
{
  req req_scene_list GET 'List orders' 'https://api.example.com/v1/orders' -5 '' ''
  req req_scene_create POST 'Create order' 'https://api.example.com/v1/orders' -4 application/json "$body"
  req req_scene_replace PUT 'Replace order' 'https://api.example.com/v1/orders/42' -3 '' ''
  req req_scene_update PATCH 'Update order' 'https://api.example.com/v1/orders/42' -2 '' ''
  req req_scene_delete DELETE 'Cancel order' 'https://api.example.com/v1/orders/42' -1 '' ''
} > "$cfg/insomnia.Request.db"

# The saved response to Create order.
cat > "$cfg/responses/res_scene_create.json" <<'JSON'
{
  "id": 42,
  "title": "Wood for the stove",
  "quantity": 12,
  "split": true,
  "delivered": null,
  "status": "queued",
  "links": { "self": "/v1/orders/42" }
}
JSON
size=$(wc -c < "$cfg/responses/res_scene_create.json")
printf '{"_id":"res_scene_create","type":"Response","parentId":"req_scene_create","modified":%s,"created":%s,"statusCode":201,"statusMessage":"Created","httpVersion":"1.1","contentType":"application/json","url":"https://api.example.com/v1/orders","bytesRead":%s,"bytesContent":%s,"elapsedTime":84,"headers":[{"name":"Content-Type","value":"application/json"}],"timelinePath":"","bodyPath":"%s","bodyCompression":null,"error":"","requestVersionId":null,"settingStoreCookies":null,"settingSendCookies":null,"environmentId":null,"requestTestResults":[],"globalEnvironmentId":null}\n' \
  "$t" "$t" "$size" "$size" "$cfg/responses/res_scene_create.json" > "$cfg/insomnia.Response.db"

# Open Create order, showing its saved response.
printf '{"_id":"wrkm_scene","type":"WorkspaceMeta","parentId":"%s","modified":%s,"created":%s,"activeActivity":null,"activeEnvironmentId":null,"activeGlobalEnvironmentId":null,"activeRequestId":"req_scene_create","activeUnitTestSuiteId":null,"gitRepositoryId":null,"gitFilePath":null,"gitFileLastSyncTime":null,"pushSnapshotOnInitialize":false,"hasUncommittedChanges":false,"hasUnpushedChanges":false}\n' \
  "$wrk" "$t" "$t" > "$cfg/insomnia.WorkspaceMeta.db"
printf '{"_id":"reqm_scene_create","type":"RequestMeta","parentId":"req_scene_create","modified":%s,"created":%s,"previewMode":"friendly","responseFilter":"","responseFilterHistory":[],"activeResponseId":"res_scene_create","savedRequestBody":{},"pinned":false,"lastActive":%s,"downloadPath":null,"expandedAccordionKeys":{},"activeMcpPrimitive":null,"streamSummaryPath":null,"streamSummaryRenderMarkdown":false}\n' \
  "$t" "$t" "$t" > "$cfg/insomnia.RequestMeta.db"
