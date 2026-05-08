# crabbox-skill

[opkg](https://openpackage.dev) package: an AI-coding-agent skill for [Crabbox](https://github.com/openclaw/crabbox), the remote-Linux-testbox runner.

Ships a `SKILL.md` + a fail-fast `preflight.sh` that runs a single `crabbox whoami` before any remote work. All broker config (URL, auth, provider) stays in the local `crabbox` CLI — works unchanged against the public openclaw.ai broker, a self-hosted Cloudflare Worker, or direct-provider mode.

## Install

```sh
opkg install gh@Minoo7/crabbox-skill -g
```

Or scoped to a single project workspace (drop `-g`).

Fans out to whichever agent skill dirs the workspace declares — `~/.claude/skills/crabbox/`, `~/.cursor/skills/crabbox/`, `~/.opencode/skills/crabbox/`, etc. — same SKILL.md + preflight.sh in each.

## Prerequisites

- [`crabbox`](https://github.com/openclaw/crabbox) CLI installed (`brew install openclaw/tap/crabbox`)
- `crabbox` logged in or configured (`crabbox login` or copy `~/.config/crabbox/config.yaml`)

The skill's preflight will tell the agent if either prereq is missing.

## License

MIT
