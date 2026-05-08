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

Install the binary, set two envs, run one command:

```sh
brew install openclaw/tap/crabbox

export CRABBOX_BROKER_URL='https://crabbox-coordinator.<your-acct>.workers.dev'
export CRABBOX_COORDINATOR_TOKEN='<shared-bearer-token>'

printf '%s' "$CRABBOX_COORDINATOR_TOKEN" | \
  crabbox login --url "$CRABBOX_BROKER_URL" --provider hetzner --token-stdin
```

`crabbox login` writes `~/.config/crabbox/config.yaml`. Re-run any time the token rotates.

For admin commands (`crabbox list` etc.), splice an admin token into that file:

```sh
config="${XDG_CONFIG_HOME:-$HOME/.config}/crabbox/config.yaml"
tmp=$(mktemp)
sed "/^    token:/a\\    adminToken: $CRABBOX_ADMIN_TOKEN" "$config" > "$tmp"
mv "$tmp" "$config"
```

## Direct-provider alternative (no broker)

If you don't have a broker, set provider creds directly:

```sh
export HCLOUD_TOKEN='<hetzner-api-token>'    # or AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY
crabbox warmup --provider hetzner --idle-timeout 30m
```

You lose coordinator-side run history (`crabbox events` / `attach` / `logs` / `results`) but lease/run/stop work.

## License

MIT
