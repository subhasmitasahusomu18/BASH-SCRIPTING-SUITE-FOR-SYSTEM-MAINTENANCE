#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/utils.sh"

MODE="${1:-scan}" # scan | --follow

scan_disk_usage() {
  log INFO "Checking disk usage..."
  while read -r line; do
    usep="$(echo "$line" | awk '{print $5}' | tr -d '%')"
    mountp="$(echo "$line" | awk '{print $6}')"
    if [[ "$usep" =~ ^[0-9]+$ ]] && (( usep >= DISK_USAGE_WARN )); then
      log WARN "High disk usage: ${usep}% on ${mountp}"
    fi
  done < <(df -hP | awk 'NR>1 {print $0}')
}

scan_failed_logins() {
  log INFO "Scanning for failed SSH logins (last 24h)..."
  if [[ -f /var/log/auth.log ]]; then
    sudo grep -i "Failed password" /var/log/auth.log | tail -n 50 | while read -r l; do log WARN "AUTH: $l"; done
  elif command -v journalctl >/dev/null 2>&1; then
    sudo journalctl -u ssh -S -24h -p warning --no-pager | tail -n 50 | while read -r l; do log WARN "AUTH: $l"; done
  else
    log WARN "No auth log or journalctl found."
  fi
}

scan_top_cpu() {
  log INFO "Listing top ${TOP_CPU_N} processes by CPU..."
  ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n $((TOP_CPU_N + 1)) | while read -r l; do log INFO "CPU: $l"; done
}

watch_loop() {
  log INFO "Entering watch mode (every ${WATCH_INTERVAL}s). Ctrl+C to exit."
  trap 'log INFO "Exiting watch mode."; exit 0' INT
  while true; do
    scan_disk_usage
    scan_top_cpu
    sleep "${WATCH_INTERVAL}"
  done
}

case "$MODE" in
  --follow)
    watch_loop
    ;;
  *)
    scan_disk_usage
    scan_failed_logins
    scan_top_cpu
    ;;
esac

log INFO "Log monitor finished."
