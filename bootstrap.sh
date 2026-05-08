#!/usr/bin/env bash
# Bootstrap the local crabbox CLI to point at your broker, from env vars.
# Idempotent. Safe to re-run.
#
# Required:
#   CRABBOX_BROKER_URL         e.g. https://crabbox-coordinator.<acct>.workers.dev
#   CRABBOX_COORDINATOR_TOKEN  shared bearer token (from the broker operator)
#
# Optional:
#   CRABBOX_ADMIN_TOKEN  enables admin commands (`crabbox list`, etc.)
#   CRABBOX_PROVIDER     default provider (hetzner|aws); defaults to hetzner
#
# After this completes, `crabbox whoami` reports the configured identity and
# the skill's preflight returns exit 0.
set -euo pipefail

red()   { printf '\033[31m%s\033[0m\n' "$*" >&2; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }

if ! command -v crabbox >/dev/null 2>&1; then
  red "crabbox CLI not on PATH. Install first:"
  red "  brew install openclaw/tap/crabbox"
  exit 2
fi

: "${CRABBOX_BROKER_URL:?set CRABBOX_BROKER_URL to your broker URL}"
: "${CRABBOX_COORDINATOR_TOKEN:?set CRABBOX_COORDINATOR_TOKEN to the bearer token}"
provider="${CRABBOX_PROVIDER:-hetzner}"

printf '%s' "$CRABBOX_COORDINATOR_TOKEN" | \
  crabbox login --url "$CRABBOX_BROKER_URL" --provider "$provider" --token-stdin >/dev/null

if [[ -n "${CRABBOX_ADMIN_TOKEN:-}" ]]; then
  config="${XDG_CONFIG_HOME:-$HOME/.config}/crabbox/config.yaml"
  # crabbox login doesn't accept --admin-token; splice it in next to `token:`.
  # Using a mktemp instead of `sed -i.bak` so we don't clobber any existing
  # `<config>.bak` file the user may have.
  tmp=$(mktemp)
  if grep -q '^    adminToken:' "$config"; then
    sed "s|^    adminToken:.*|    adminToken: ${CRABBOX_ADMIN_TOKEN}|" "$config" > "$tmp"
  else
    sed "/^    token:/a\\
    adminToken: ${CRABBOX_ADMIN_TOKEN}" "$config" > "$tmp"
  fi
  mv "$tmp" "$config"
  chmod 600 "$config"
fi

green "crabbox bootstrap complete"
crabbox whoami
