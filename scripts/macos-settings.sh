#!/usr/bin/env bash
set -euo pipefail

LABEL="com.basils.dotfiles.key-remap"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
CAPS_LOCK_TO_CONTROL='{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":30064771129,"HIDKeyboardModifierMappingDst":30064771296}]}'

usage() {
  cat <<'USAGE'
Usage: ./scripts/macos-settings.sh --apply|--check

Applies or checks tracked macOS settings.
USAGE
}

require_macos() {
  if [ "$(uname)" != "Darwin" ]; then
    echo "skip: macOS settings only apply on Darwin"
    exit 0
  fi
}

apply_key_remap() {
  echo "apply: Caps Lock -> Control"
  hidutil property --set "$CAPS_LOCK_TO_CONTROL" >/dev/null
}

apply_trackpad_settings() {
  echo "apply: natural trackpad scrolling off"
  defaults write -g com.apple.swipescrolldirection -bool false
}

run_pmset() {
  if [ "$(id -u)" -eq 0 ]; then
    pmset "$@"
  else
    sudo pmset "$@"
  fi
}

apply_power_settings() {
  echo "apply: never idle sleep or turn off display"
  run_pmset -a displaysleep 0 sleep 0 >/dev/null

  echo "apply: keep battery display brightness unchanged"
  run_pmset -b lessbright 0 >/dev/null

  if pmset_profile_has_setting "Battery Power" lowpowermode; then
    echo "apply: Low Power Mode off on battery"
    run_pmset -b lowpowermode 0 >/dev/null
  fi

  if pmset_profile_has_setting "AC Power" lowpowermode; then
    echo "apply: Low Power Mode off on power adapter"
    run_pmset -c lowpowermode 0 >/dev/null
  fi
}

apply_dock_settings() {
  if ! command -v dockutil >/dev/null 2>&1; then
    echo "warning: dockutil is not installed; skipping Dock cleanup" >&2
    return 1
  fi

  echo "apply: remove pinned Dock apps"
  dockutil --list |
    awk -F'\t' '$3 == "persistentApps" { print ($5 != "" ? $5 : $1) }' |
    while IFS= read -r item; do
      [ -n "$item" ] || continue
      dockutil --remove "$item" --no-restart >/dev/null || true
    done

  echo "apply: hide recent applications in Dock"
  defaults write com.apple.dock show-recents -bool false
  killall Dock >/dev/null 2>&1 || true
}

load_key_remap_agent() {
  local domain
  domain="gui/$(id -u)"

  if [ ! -e "$PLIST" ]; then
    echo "warning: $PLIST is missing; run ./link.sh to install the LaunchAgent" >&2
    return 1
  fi

  launchctl bootout "$domain" "$PLIST" >/dev/null 2>&1 || true
  if launchctl bootstrap "$domain" "$PLIST" >/dev/null 2>&1; then
    echo "load: $LABEL"
  else
    launchctl kickstart -k "$domain/$LABEL" >/dev/null 2>&1 || {
      echo "warning: could not load $LABEL; it should load at next login" >&2
      return 1
    }
  fi
}

pmset_profile_has_setting() {
  local profile="$1"
  local setting="$2"

  pmset -g custom | awk -v profile="$profile:" -v setting="$setting" '
    $0 == profile {
      in_profile = 1
      next
    }
    /^[^[:space:]].*:$/ {
      in_profile = 0
    }
    in_profile && $1 == setting {
      found = 1
      exit
    }
    END {
      exit found ? 0 : 1
    }
  '
}

pmset_profile_value() {
  local profile="$1"
  local setting="$2"

  pmset -g custom | awk -v profile="$profile:" -v setting="$setting" '
    $0 == profile {
      in_profile = 1
      next
    }
    /^[^[:space:]].*:$/ {
      in_profile = 0
    }
    in_profile && $1 == setting {
      print $2
      found = 1
      exit
    }
    END {
      exit found ? 0 : 1
    }
  '
}

check_pmset_value() {
  local profile="$1"
  local setting="$2"
  local expected="$3"
  local label="$4"
  local current

  if ! current="$(pmset_profile_value "$profile" "$setting")"; then
    echo "skip: $label is not reported for $profile"
    return 0
  fi

  if [ "$current" = "$expected" ]; then
    echo "ok: $label"
  else
    echo "drift: $label expected '$expected' but found '$current'"
    return 1
  fi
}

check_power_settings() {
  local status=0

  check_pmset_value "Battery Power" displaysleep 0 "battery display sleep disabled" || status=1
  check_pmset_value "Battery Power" sleep 0 "battery system sleep disabled" || status=1
  check_pmset_value "Battery Power" lessbright 0 "battery display dimming disabled" || status=1
  check_pmset_value "Battery Power" lowpowermode 0 "battery Low Power Mode off" || status=1
  check_pmset_value "AC Power" displaysleep 0 "power adapter display sleep disabled" || status=1
  check_pmset_value "AC Power" sleep 0 "power adapter system sleep disabled" || status=1
  check_pmset_value "AC Power" lowpowermode 0 "power adapter Low Power Mode off" || status=1

  return "$status"
}

check_key_remap() {
  local current
  current="$(hidutil property --get UserKeyMapping 2>/dev/null || true)"

  if [[ "$current" == *"30064771129"* && "$current" == *"30064771296"* ]]; then
    echo "ok: Caps Lock -> Control"
  else
    echo "drift: Caps Lock -> Control is not active"
    return 1
  fi
}

check_trackpad_settings() {
  local scroll_direction
  scroll_direction="$(defaults read -g com.apple.swipescrolldirection 2>/dev/null || printf '1')"

  if [ "$scroll_direction" = "0" ]; then
    echo "ok: natural trackpad scrolling off"
  else
    echo "drift: natural trackpad scrolling is on"
    return 1
  fi
}

check_dock_settings() {
  local status=0
  local pinned_count show_recents

  if ! command -v dockutil >/dev/null 2>&1; then
    echo "missing: dockutil"
    return 1
  fi

  pinned_count="$(dockutil --list 2>/dev/null | awk -F'\t' '$3 == "persistentApps" { count++ } END { print count + 0 }')"
  if [ "$pinned_count" -eq 0 ]; then
    echo "ok: Dock has no pinned apps"
  else
    echo "drift: Dock has $pinned_count pinned app(s)"
    status=1
  fi

  show_recents="$(defaults read com.apple.dock show-recents 2>/dev/null || printf '1')"
  if [ "$show_recents" = "0" ]; then
    echo "ok: Dock recent applications hidden"
  else
    echo "drift: Dock recent applications are visible"
    status=1
  fi

  return "$status"
}

case "${1:-}" in
--apply)
  require_macos
  apply_key_remap
  apply_trackpad_settings
  apply_power_settings
  apply_dock_settings
  load_key_remap_agent
  ;;
--check)
  require_macos
  status=0
  check_key_remap || status=1
  check_trackpad_settings || status=1
  check_power_settings || status=1
  check_dock_settings || status=1
  exit "$status"
  ;;
*)
  usage >&2
  exit 1
  ;;
esac
