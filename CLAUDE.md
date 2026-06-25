# CLAUDE.md — thiagowfx/skills

Personal Claude Code skills, shipped as a plugin marketplace.

## Source of truth

This repo is the source of truth for these skills — **not** `~/.dotfiles/claude/.claude/skills/`.
Edit skills here. (Dotfiles consuming from this repo is a planned follow-up.)

## Layout

- `.claude-plugin/marketplace.json` — marketplace manifest. Marketplace name: `thiagowfx`.
- `plugins/skills/.claude-plugin/plugin.json` — the single plugin, name `skills`.
- `plugins/skills/skills/<name>/SKILL.md` — one directory per skill. Skills are
  auto-discovered; do not list them in `plugin.json`.

## Add a skill

1. `mkdir plugins/skills/skills/<name>` and write `SKILL.md`.
2. `SKILL.md` frontmatter requires `name:` and `description:`. The `description` is what Claude
   matches against to decide when to invoke — make it trigger-rich (mention the phrases a user
   would say).
3. Add a row to the README skills table.
4. Bump `version` in `plugin.json` (users only get updates when it changes).

## Validate

```sh
jq . .claude-plugin/marketplace.json
jq . plugins/skills/.claude-plugin/plugin.json
```
