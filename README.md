# skills

Thiago's personal Gen-AI / Claude Code [skills](https://code.claude.com/docs/en/skills),
distributed as a native Claude Code [plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces).

## Install

```
/plugin marketplace add thiagowfx/skills
/plugin install skills@thiagowfx
```

`/plugin marketplace update thiagowfx` to pull later changes.

## Skills

| Skill | Description |
| --- | --- |
| `address-pr-comments` | Fetch PR review comments and address them. |
| `bloggify` | Draft a blog post for perrotta.dev in the existing house style. |
| `catchup` | Refresh context on the current repo — uncommitted changes, recent commits, open PRs, worktrees, stashes, plans, handoff notes. |
| `find-skills` | Discover and install agent skills when looking for functionality that might exist as a skill. |
| `gha` | Analyze GitHub Actions failures and identify root causes. |
| `grill-me` | Interview you relentlessly about a plan or design until shared understanding. |
| `new-apkbuild` | Scaffold and iterate on an Alpine Linux APKBUILD for a new aport. |
| `pr-pass` | Push, wait for CI, fix failures, loop until all checks pass. |
| `ship` | Commit changes (if any) and send a PR for review. |

## Layout

```
.claude-plugin/marketplace.json   # marketplace manifest
plugins/skills/                    # the "skills" plugin
  .claude-plugin/plugin.json       # plugin manifest
  skills/<name>/SKILL.md           # one dir per skill (auto-discovered)
```

## Credits

Inspired by [JuliusBrussee/skills](https://github.com/JuliusBrussee/skills).
