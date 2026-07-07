# ADR-0001: Adopt dotagents for cross-agent skill distribution

## Status

Proposed

## Date

2026-07-07

## Context

These skills are authored once as plain `SKILL.md` directories but consumed by a growing set of
coding agents, each with its own install location:

| Agent | Skills directory |
| --- | --- |
| Claude Code | `~/.claude/skills/` (project: `.claude/skills/`) |
| pi ([pi.dev](https://pi.dev)) | `~/.pi/agent/` |
| Codex CLI | `~/.codex/skills/` (project: `.codex/skills/`) |
| Cursor / opencode | their own dirs |

`SKILL.md` is now a cross-agent open standard — Claude Code, Codex, pi, Cursor, and opencode
all read the same `name`/`description` frontmatter and load the body on demand. The
skill *content* is portable; only the *install/symlink layer* differs per agent.

Today this repo ships two delivery paths, both documented in the README:

1. **Claude Code plugin marketplace** (`.claude-plugin/marketplace.json`) — native, versioned,
   namespaced (`/thiagowfx:ship`). Claude Code only.
2. **`npx skills` ([vercel-labs/skills](https://github.com/vercel-labs/skills))** — the current
   cross-agent story. Copies plain `SKILL.md` files into a target agent's dir. No namespacing, no
   versioned updates.

The open question: as the number of consuming agents grows past two or three, is `npx skills`
(copy-on-demand, per-agent, manual re-run to update) still the right cross-agent mechanism, or
should this repo adopt [dotagents](https://docs.sentry.io/ai/dotagents/) — Sentry's declarative
skill package manager — for the consumer side?

## Decision

**Proposed: do not migrate distribution to dotagents. Keep the plugin marketplace as the Claude
Code path and `npx skills` as the cross-agent path. Optionally document dotagents as a supported
*consumer-side* install for users who already manage skills across several agents.**

dotagents solves the N-agent fan-out with an `agents.toml` (declared skill dependencies) plus an
`agents.lock` (commit + SHA-256 pinning), storing skills in `.agents/skills/` and symlinking them
into each agent's expected dir. That is genuinely the right shape for "one skill, many agents, one
source of truth" — the problem this repo will have once Claude Code, pi, and Codex are all in play.

But it is a *consumer-side* tool, and this repo is a *producer*. The producer keeps publishing
plain `SKILL.md` dirs (unchanged); whether a consumer pulls them via marketplace, `npx skills`, or
dotagents is their choice. Adopting dotagents *in this repo* would not change what is published —
so the decision is really "which install path do we recommend and document," not "how do we build."

### Rationale

- **The producer format does not change either way.** `SKILL.md` is the open standard; all three
  mechanisms consume it. Nothing about the repo layout (`plugins/thiagowfx/skills/<name>/`) needs
  to move for dotagents to work against it.
- **`npx skills` already covers the cross-agent case.** It is the incumbent, it is already
  documented, and it installs into any agent's dir today. dotagents' marginal gain over it is a
  lockfile and a declarative manifest — real, but not yet load-bearing at two agents.
- **The marketplace is strictly better on Claude Code** (versioned updates via `just bump`,
  `/thiagowfx:` namespacing). dotagents offers neither. So on Claude Code, dotagents is a
  downgrade; it only competes on the *other* agents, where it competes with `npx skills`.
- **dotagents is beta and adds an `npx @sentry/dotagents` runtime dependency.** Recommending it as
  the default cross-agent path trades a working incumbent for a beta tool for a marginal gain.

### The one real gap dotagents closes

`npx skills` copies files at a point in time with no version pin — re-running pulls latest HEAD.
dotagents' `agents.lock` pins each skill to a commit + hash, giving reproducible cross-agent
installs. This matters *if and when*:

- a teammate needs the exact same skill versions across their agents, or
- an agent's skill set must be reproducible from a committed manifest.

Neither is true for a single user with two agents today. If it becomes true (more agents, shared
setup, "why did this skill change under me"), revisit — dotagents is the clean answer at that
point, and because the producer format is unchanged, adopting it later is cheap.

### Alternatives considered

- **Migrate the cross-agent path from `npx skills` to dotagents now.** Rejected: swaps a working,
  documented incumbent for a beta tool to gain a lockfile that no current consumer needs. Revisit
  when reproducibility across agents becomes a real requirement.
- **Home-grown stow / symlink loop** (as the dotfiles repo does for a few loose skills). Works for
  two hardcoded targets; degrades as each new agent adds another hardcoded path and there is still
  no shared version pin. This is exactly the maintenance burden dotagents removes — so if the DIY
  loop ever grows past a couple of targets, prefer dotagents over extending the loop.
- **Do nothing / marketplace only.** Rejected: abandons every non-Claude-Code agent, which is the
  whole reason the cross-agent path exists.

## Consequences

- **No repo change required.** The producer keeps shipping `SKILL.md` dirs; the marketplace and
  `npx skills` paths in the README stay as-is. This ADR records *why* dotagents was not adopted, so
  the question does not get re-litigated on every new agent.
- **A clear trigger to revisit.** The moment reproducible, version-pinned skills are needed across
  three or more agents — or a teammate needs an identical multi-agent setup — dotagents becomes the
  recommended consumer-side tool. Because the producer format is unchanged, adopting it is a
  documentation change plus an `agents.toml`, not a migration.
- **README may gain an optional dotagents note.** For users already on dotagents, a one-line
  "install via `agents.toml` pointing at `thiagowfx/skills`" is worth documenting alongside the
  existing marketplace and `npx skills` sections — as an option, not the default.
- **Verify target-dir support before recommending it.** dotagents' docs emphasize `.claude/` and
  `.cursor/` targets; confirm it supports arbitrary dirs (`~/.pi/agent/`, `~/.codex/skills/`)
  before pointing anyone at it for pi or Codex. If target dirs are not configurable, the gap it
  closes shrinks and `npx skills` stays ahead.
