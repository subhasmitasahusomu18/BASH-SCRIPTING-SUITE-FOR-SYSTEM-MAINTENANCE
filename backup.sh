#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/utils.sh"

need_cmd rsync

mkdir -p "$BACKUP_DEST"

DATE_TAG="$(date '+%Y%m%d-%H%M%S')"
DEST_DIR="${BACKUP_DEST}/backup-${DATE_TAG}"
LAST_BACKUP="$(ls -1dt "${BACKUP_DEST}"/backup-* 2>/dev/null | head -n 1 || true)"

log INFO "Starting backup to $DEST_DIR"
mkdir -p "$DEST_DIR"

DRYRUN="${BACKUP_DRYRUN_DEFAULT:-false}"
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRYRUN="true" ;;
    --no-dry-run) DRYRUN="false" ;;
  esac
done

RSYNC_OPTS=(-aAX --delete --human-readable --info=stats1,progress2)
[[ "$DRYRUN" == "true" ]] && RSYNC_OPTS+=(-n)

if [[ -n "${BACKUP_EXCLUDES_FILE:-}" && -f "$BACKUP_EXCLUDES_FILE" ]]; then
  RSYNC_OPTS+=(--exclude-from="$BACKUP_EXCLUDES_FILE")
fi
if [[ -n "$LAST_BACKUP" && -d "$LAST_BACKUP" ]]; then
  RSYNC_OPTS+=(--link-dest="$LAST_BACKUP")
fi

# Support multiple sources
for SRC in $BACKUP_SRC; do
  NAME="$(basename "$SRC")"
  if [[ -e "$SRC" ]]; then
    log INFO "Backing up $SRC -> $DEST_DIR/$NAME (dry-run=$DRYRUN)"
    rsync "${RSYNC_OPTS[@]}" "$SRC"/ "$DEST_DIR/$NAME"/
  else
    log WARN "Source not found: $SRC (skipping)"
  fi
done

if [[ "$DRYRUN" == "false" ]]; then
  log INFO "Pruning backups older than ${BACKUP_RETAIN_DAYS} days in $BACKUP_DEST"
  rotate_old_backups "$BACKUP_DEST" "$BACKUP_RETAIN_DAYS"
fi

log INFO "Backup routine finished."
