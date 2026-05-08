#!/usr/bin/env bash
# Crabbox skill preflight: agents MUST run this before any crabbox command.
#
# DUPLICATED in install-agent-skill.sh as a quoted heredoc — keep in sync.
#
# Exit codes:
#   0  ready — stdout has whoami summary
#   2  CLI not installed
#   4  CLI present but whoami failed (not configured / broker unreachable /
#      binary broken — captured error is on stderr)
#
# Notes on `set`: we use `-uo pipefail` (no `-e`) intentionally. Every
# fallible command below is gated by `if !` or captured into a variable
# with explicit handling. Adding `-e` would conflict with `if !` semantics.
set -uo pipefail

red()   { printf '\033[31m%s\033[0m\n' "$*" >&2; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }

if ! command -v crabbox >/dev/null 2>&1; then
  red "crabbox CLI not installed."
  cat >&2 <<'EOF'
Install with one of:
  brew install openclaw/tap/crabbox
  # or download a release archive:
  # https://github.com/openclaw/crabbox/releases/latest
Then re-run this preflight.
EOF
  exit 2
fi

if ! whoami_out=$(crabbox whoami 2>&1); then
  red "crabbox whoami failed:"
  printf '%s\n' "$whoami_out" >&2
  cat >&2 <<'EOF'
The CLI is on PATH but cannot report identity. Likely causes:
  - not configured / not logged in
  - broker URL in config is unreachable
  - binary cannot run (exec error)

If the user wants to authenticate, options are:
  crabbox login                                                       # GitHub OAuth (browser)
  printf '%s' "$TOKEN" | crabbox login --url <broker> --token-stdin   # shared bearer token
  # or set HCLOUD_TOKEN / AWS keys + use --provider hetzner|aws       # direct-provider, no broker

Do not run any of these without explicit user instruction.
EOF
  exit 4
fi

green "crabbox preflight OK"
printf 'whoami: %s\n' "$whoami_out"
exit 0
