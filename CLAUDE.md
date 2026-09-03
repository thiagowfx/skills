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
4. Follow the release rule below.

## Release changes

Before committing any change under `plugins/thiagowfx/`, run `just bump` once for that commit.
Use `just bump minor` or `just bump major` when needed. This updates both
`plugins/thiagowfx/.claude-plugin/plugin.json` and `package.json`. Include both files in the same
commit as the plugin change. Users only receive plugin updates when this version changes.

Manifest JSON validity is enforced by the `check-json` prek hook on commit.
