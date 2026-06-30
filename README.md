# skills

Thiago's personal Gen-AI / Claude Code [skills](https://code.claude.com/docs/en/skills),
distributed as a native Claude Code [plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces).

## Install

```text
/plugin marketplace add thiagowfx/skills
/plugin install thiagowfx@thiagowfx
```

`/plugin marketplace update thiagowfx` to pull later changes.

### Other agents (opencode, pi, cursor...)

The plugin marketplace is Claude Code-only. On any other agent, the same `SKILL.md`
files install via the cross-agent [`skills` CLI](https://github.com/vercel-labs/skills):

```bash
npx skills add thiagowfx/skills          # all skills, into ./.claude/skills
npx skills add thiagowfx/skills -g       # global (~/.claude/skills)
npx skills add thiagowfx/skills -l       # list without installing
npx skills add thiagowfx/skills -s ship  # one skill
```

This copies plain `SKILL.md` files — without the plugin's `/thiagowfx:` namespacing
or versioned updates. Prefer the marketplace above on Claude Code.

## Skills

| Skill | Description |
| --- | --- |
| `address-pr-comments` | Fetch PR review comments and address them. |
| `bloggify` | Draft a blog post for perrotta.dev in the existing house style. |
| `catchup` | Refresh context on the current repo — uncommitted changes, commits, open PRs, worktrees, stashes, plans. |
| `find-skills` | Discover and install agent skills when looking for functionality that might exist as a skill. |
| `gha` | Analyze GitHub Actions failures and identify root causes. |
| `handoff` | Compact the current conversation into a handoff document for another agent to pick up. |
| `grill-me` | Interview you relentlessly about a plan or design until shared understanding. |
| `new-apkbuild` | Scaffold and iterate on an Alpine Linux APKBUILD for a new aport. |
| `pr-pass` | Push, wait for CI, fix failures, loop until all checks pass. |
| `ship` | Commit changes (if any) and send a PR for review. |
| `tdd` | Test-driven development — red-green-refactor via vertical tracer-bullet slices. |

## Layout

```text
.claude-plugin/marketplace.json   # marketplace manifest
plugins/thiagowfx/                 # the "thiagowfx" plugin
  .claude-plugin/plugin.json       # plugin manifest
  skills/<name>/SKILL.md           # one dir per skill (auto-discovered)
```

## Credits

Inspired by [JuliusBrussee/skills](https://github.com/JuliusBrussee/skills).

`grill-me`, `handoff`, and `tdd` are derived from [mattpocock/skills](https://github.com/mattpocock/skills)
(MIT © Matt Pocock); `find-skills` from [vercel-labs/skills](https://github.com/vercel-labs/skills)
(MIT © Vercel). See [THIRD_PARTY.md](THIRD_PARTY.md).
