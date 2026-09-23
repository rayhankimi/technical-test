#!/usr/bin/env bash

set -euo pipefail
export TZ=Asia/Jakarta

API_URL="${API_URL:-http://api:8000}"
OUT_DIR="${OUT_DIR:-/data/snapshots}"
WIB_OFFSET=25200

log() { printf '%s [snapshot] %s\n' "$(date +%Y-%m-%dT%H:%M:%S%z)" "$*"; }

# --- Resolve "now"
if [[ -z ${SNAPSHOT_AT:-} ]]; then
  now=$(date +%s)
elif [[ $SNAPSHOT_AT =~ ^[0-9]+$ ]]; then
  now=$SNAPSHOT_AT
else
  now=$(date -d "$SNAPSHOT_AT" +%s) || { log "ERROR: cannot parse SNAPSHOT_AT='$SNAPSHOT_AT'"; exit 2; }
fi

# Find the window to avoid delay in creating snapshot especially when the server experienced downtime
day=$(( (now + WIB_OFFSET) / 86400 * 86400 - WIB_OFFSET ))   # 00:00 WIB today
slots=(
  $((day - 12 * 3600))   # 12:00 yesterday
  $((day -  9 * 3600))   # 15:00 yesterday
  $((day +  8 * 3600))   # 08:00
  $((day + 12 * 3600))   # 12:00
  $((day + 15 * 3600))   # 15:00
)
idx=1                    # 15:00 yesterday is always <= now
for i in 2 3 4; do
  if (( slots[i] <= now )); then idx=$i; fi
done
start=${slots[idx - 1]}
end=${slots[idx]}

from_utc=$(date -u -d "@$start" +%Y-%m-%dT%H:%M:%SZ)
to_utc=$(date -u -d "@$end" +%Y-%m-%dT%H:%M:%SZ)
name="usage_snapshot_$(date -d "@$end" +%Y%m%d_%H%M)_WIB.csv"

# --- Fetch and write atomically ----------------------------------------------
mkdir -p "$OUT_DIR"
json="$OUT_DIR/.$name.json"
tmp="$OUT_DIR/.$name.tmp"
trap 'rm -f "$json" "$tmp"' EXIT

log "window $(date -d "@$start" '+%F %H:%M') -> $(date -d "@$end" '+%F %H:%M') WIB ($from_utc .. $to_utc)"

if ! curl --silent --show-error --fail \
     --retry 3 --retry-delay 5 --retry-connrefused --max-time 10 \
     -G "$API_URL/usages" \
     --data-urlencode "from=$from_utc" --data-urlencode "to=$to_utc" \
     -o "$json"; then
  log "ERROR: request to $API_URL/usages failed; no file written"
  exit 1
fi

# JSON -> CSV. Timestamps are converted from UTC to WIB with an explicit offset.
if ! jq -r --argjson off "$WIB_OFFSET" '
    (if type == "array" then . else error("expected a JSON array") end) as $rows
    | ["id", "subscriberId", "callMinutes", "smsCount", "dataUsageMB", "timestamp"],
      ($rows[] | [
        .id, .subscriberId, .callMinutes, .smsCount, .dataUsageMB,
        (.timestamp | sub("\\.[0-9]+"; "") | sub("\\+00:00$"; "Z")
          | fromdateiso8601 + $off | strftime("%Y-%m-%dT%H:%M:%S+07:00"))
      ])
    | @csv' "$json" > "$tmp"; then
  log "ERROR: could not convert the API response to CSV; no file written"
  exit 1
fi

rows=$(jq length "$json")
mv "$tmp" "$OUT_DIR/$name"
log "wrote $name ($rows records)"