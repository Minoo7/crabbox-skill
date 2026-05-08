# crabbox-skill

[opkg](https://openpackage.dev) package: an AI-coding-agent skill for [Crabbox](https://github.com/openclaw/crabbox), the remote-Linux-testbox runner.

Ships a `SKILL.md` + a fail-fast `preflight.sh` that runs a single `crabbox whoami` before any remote work. All broker config (URL, auth, provider) stays in the local `crabbox` CLI — works unchanged against the public openclaw.ai broker, a self-hosted Cloudflare Worker, or direct-provider mode.

## Install the skill

```sh
opkg install gh@Minoo7/crabbox-skill -g
```

(Drop `-g` to install into the current project workspace only.)

Fans out to whichever agent skill dirs the workspace declares — `~/.claude/skills/crabbox/`, `~/.cursor/skills/crabbox/`, `~/.opencode/skills/crabbox/`, etc.

## Bootstrap the CLI on a new machine

The skill expects `crabbox whoami` to succeed. On a fresh box:

```sh
brew install openclaw/tap/crabbox            # CLI binary

export CRABBOX_BROKER_URL='https://crabbox-coordinator.<your-acct>.workers.dev'
export CRABBOX_COORDINATOR_TOKEN='<shared-bearer-token>'
export CRABBOX_ADMIN_TOKEN='<admin-token>'   # optional — enables `crabbox list`

bash <(curl -fsSL https://raw.githubusercontent.com/Minoo7/crabbox-skill/main/bootstrap.sh)
```

`bootstrap.sh` runs `crabbox login --token-stdin` and (if provided) splices `adminToken` into the resulting `~/.config/crabbox/config.yaml`. Idempotent — re-run any time the token rotates.

For fish-shell users wanting persistent envs:

```fish
set -Ux CRABBOX_BROKER_URL "https://crabbox-coordinator.<your-acct>.workers.dev"
set -Ux CRABBOX_COORDINATOR_TOKEN "<shared-bearer-token>"
set -Ux CRABBOX_ADMIN_TOKEN "<admin-token>"
```

Or stash them in `sops`-encrypted env files and source on shell start.

## Direct-provider alternative (no broker)

If you don't have a broker, set provider creds directly and skip bootstrap:

```sh
export HCLOUD_TOKEN='<hetzner-api-token>'    # or AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY
crabbox warmup --provider hetzner --idle-timeout 30m
```

You lose coordinator-side run history (`crabbox events` / `attach` / `logs` / `results`) but lease/run/stop all work.

## License

MIT
