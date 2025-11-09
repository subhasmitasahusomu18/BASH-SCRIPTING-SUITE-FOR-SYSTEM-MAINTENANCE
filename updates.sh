#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/utils.sh"

PM="$(pkg_manager)"
log INFO "Detected package manager: $PM"

case "$PM" in
  apt)
    need_cmd apt-get
    sudo -n true 2>/dev/null || log WARN "This may prompt for sudo."
    log INFO "Refreshing package lists..."
    sudo apt-get update
    log INFO "Upgrading packages..."
    if [[ "${UPDATES_YES:-false}" == "true" ]]; then
      sudo apt-get -y upgrade
    else
      sudo apt-get upgrade
    fi
    log INFO "Autoremove and clean..."
    sudo apt-get -y autoremove
    sudo apt-get clean
    ;;
  dnf)
    need_cmd dnf
    sudo -n true 2>/dev/null || log WARN "This may prompt for sudo."
    log INFO "Upgrading packages..."
    if [[ "${UPDATES_YES:-false}" == "true" ]]; then
      sudo dnf -y upgrade
    else
      sudo dnf upgrade
    fi
    log INFO "Cleaning metadata..."
    sudo dnf clean all
    ;;
  pacman)
    need_cmd pacman
    sudo -n true 2>/dev/null || log WARN "This may prompt for sudo."
    log INFO "Synchronizing and upgrading packages..."
    if [[ "${UPDATES_YES:-false}" == "true" ]]; then
      sudo pacman -Syu --noconfirm
    else
      sudo pacman -Syu
    fi
    log INFO "Cleaning cache..."
    sudo pacman -Sc --noconfirm
    ;;
  *)
    log ERROR "Unsupported or unknown package manager."
    exit 2
    ;;
esac

log INFO "Update routine finished."
