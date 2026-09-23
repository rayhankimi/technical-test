#!/usr/bin/env bash

set -euo pipefail
export TZ=Asia/Jakarta

OUT_DIR="${OUT_DIR:-/data/snapshots}"
RETENTION_DAYS="${RETENTION_DAYS:-30}"
DRY_RUN="${DRY_RUN:-0}"

log() { printf '%s [cleanup] %s\n' "$(date +%Y-%m-%dT%H:%M:%S%z)" "$*"; }

if [[ ! $RETENTION_DAYS =~ ^[0-9]+$ ]]; then
  log "ERROR: invalid RETENTION_DAYS (not whole number), RETENTION_DAYS :'$RETENTION_DAYS'"
  exit 2
fi
if [[ ! -d $OUT_DIR ]]; then
  log "nothing to do: $OUT_DIR does not exist"
  exit 0
fi

cutoff=$(date -d "@$(( $(date +%s) - RETENTION_DAYS * 86400 ))" +%Y%m%d_%H%M)
log "deleting snapshots older than $RETENTION_DAYS days (before ${cutoff} WIB)$([[ $DRY_RUN == 1 ]] && echo ', dry run')"

shopt -s nullglob
deleted=0
kept=0
for f in "$OUT_DIR"/usage_snapshot_*_WIB.csv; do
  base=${f##*/}
  if [[ ! $base =~ ^usage_snapshot_([0-9]{8}_[0-9]{4})_WIB\.csv$ ]]; then
    log "skip (name does not match the convention): $base"
    continue
  fi
  if [[ ${BASH_REMATCH[1]} < "$cutoff" ]]; then
    if [[ $DRY_RUN == 1 ]]; then
      log "would delete $base"
    else
      rm -f -- "$f"
      log "deleted $base"
    fi
    deleted=$((deleted + 1))
  else
    kept=$((kept + 1))
  fi
done

log "done: $deleted $([[ $DRY_RUN == 1 ]] && echo 'to delete' || echo 'deleted'), $kept kept"