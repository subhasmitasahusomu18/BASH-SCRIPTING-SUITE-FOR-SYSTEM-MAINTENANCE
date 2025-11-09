#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/utils.sh"

title() {
  echo "==== Bash Maintenance Suite ===="
  echo "Repo: $(basename "$ROOT_DIR")"
  echo "Log: ${SUITE_LOG}"
  echo
}

run_script() {
  local s="$1"; shift || true
  bash "$SCRIPT_DIR/$s" "$@"
}

while true; do
  title
  echo "1) Backup now"
  echo "2) Update & clean system"
  echo "3) Scan logs & system"
  echo "4) Watch system (follow mode)"
  echo "5) Show suite log (last 200 lines)"
  echo "6) Exit"
  echo
  read -r -p "Choose an option [1-6]: " choice || true
  case "$choice" in
    1) run_script backup.sh ;;
    2) run_script updates.sh ;;
    3) run_script log_monitor.sh ;;
    4) run_script log_monitor.sh --follow ;;
    5) tail -n 200 "${SUITE_LOG:-$ROOT_DIR/suite.log}" || echo "No log yet." ;;
    6) echo "Bye!"; exit 0 ;;
    *) echo "Invalid choice." ;;
  esac
  echo; read -r -p "Press Enter to continue..." _ || true
done
