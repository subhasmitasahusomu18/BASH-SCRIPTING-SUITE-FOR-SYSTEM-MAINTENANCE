#!/usr/bin/env bash
set -Eeuo pipefail

# Resolve dirs
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="${ROOT_DIR}/config.env"
EXAMPLE_CONFIG="${ROOT_DIR}/config.env.example"

# Load config
if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
else
  echo "Config file not found: $CONFIG_FILE"
  echo "Copy $EXAMPLE_CONFIG to $CONFIG_FILE and customize."
  exit 1
fi

SUITE_LOG="${SUITE_LOG:-$ROOT_DIR/suite.log}"
touch "$SUITE_LOG" 2>/dev/null || true

log() {
  local level="$1"; shift
  local msg="$*"
  printf "[%s] [%s] %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$msg" | tee -a "$SUITE_LOG"
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || { log ERROR "Required command '$1' not found."; return 1; }
}

pkg_manager() {
  if command -v apt-get >/dev/null 2>&1; then echo "apt"; return; fi
  if command -v dnf >/dev/null 2>&1; then echo "dnf"; return; fi
  if command -v pacman >/dev/null 2>&1; then echo "pacman"; return; fi
  echo "unknown"
}

confirm() {
  local prompt="${1:-Proceed?}"
  read -r -p "$prompt [y/N]: " ans || true
  [[ "${ans,,}" == "y" || "${ans,,}" == "yes" ]]
}

rotate_old_backups() {
  local dest="$1" days="$2"
  find "$dest" -maxdepth 1 -type d -name 'backup-*' -mtime "+$days" -print -exec rm -rf {} \; 2>/dev/null || true
}
