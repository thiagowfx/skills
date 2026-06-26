# CLAUDE.md — thiagowfx/skills

Personal Claude Code skills, shipped as a plugin marketplace.

## Layout

- `.claude-plugin/marketplace.json` — marketplace manifest. Marketplace name: `thiagowfx`.
- `plugins/thiagowfx/.claude-plugin/plugin.json` — the single plugin, name `thiagowfx`. This
  name is the skill-invocation namespace (e.g. `/thiagowfx:ship`), not `displayName`.
- `plugins/thiagowfx/skills/<name>/SKILL.md` — one directory per skill. Skills are
  auto-discovered; do not list them in `plugin.json`.

## Add a skill

1. `mkdir plugins/thiagowfx/skills/<name>` and write `SKILL.md`.
2. `SKILL.md` frontmatter requires `name:` and `description:`. The `description` is what Claude
   matches against to decide when to invoke — make it trigger-rich (mention the phrases a user
   would say).
3. Add a row to the README skills table.
4. `just bump` (or `just bump minor` / `major`) — bumps `version` in `plugin.json`; users only
   get updates when it changes.

Manifest JSON validity is enforced by the `check-json` prek hook on commit.
