---
name: find-skills
description: Discover and install agent skills. Use when the user asks "find a skill for X", "is there a skill for X", "how do I do X", or wants to extend Claude's capabilities with installable skills.
model: sonnet
---

Discover and install skills from the open agent skills ecosystem.

## Skills CLI

`npx skills` — package manager for agent skills.

- `npx skills find [query]` — search by keyword
- `npx skills add <package>` — install from GitHub
- `npx skills check` / `npx skills update` — update installed skills

Browse: <https://skills.sh/>

## Steps

### 1. Check the leaderboard first

Visit <https://skills.sh/> — ranked by installs. Top picks for web dev:

- `vercel-labs/agent-skills` — React, Next.js, design
- `anthropics/skills` — frontend, document processing

### 2. Search if needed

```bash
npx skills find [query]
```

Examples: `npx skills find react performance`, `npx skills find pr review`

### 3. Verify before recommending

- Prefer 1K+ installs; be cautious under 100
- Official sources (`vercel-labs`, `anthropics`, `microsoft`) more trustworthy
- Check GitHub stars on the source repo

### 4. Present and install

Show: name, install count, source, install command, skills.sh link.

Install when user confirms:

```bash
npx skills add <owner/repo@skill> -g -y
```

(`-g` = global, `-y` = skip prompts)

### 5. If nothing found

Say no match, offer to help directly, suggest `npx skills init my-skill` for recurring tasks.
