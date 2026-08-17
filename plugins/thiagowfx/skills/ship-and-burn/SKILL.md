---
name: ship-and-burn
description: Ship a pull request, make its checks pass, then delete its local branch and worktree. Use whenever the user says "/ship-and-burn", "ship and burn", "burn after shipping", "ship it, get CI green, and clean up", or wants the ship and pr-pass skills followed by local cleanup.
argument-hint: "[reviewer]"
---

# Ship and Burn

Run each phase in order. Stop when a phase fails. Do not burn local state unless `pr-pass` reports that all checks pass.

## 1. Ship

Load `../ship/SKILL.md` and execute its full workflow. Pass `$ARGUMENTS` to it as its reviewer argument.

Use native skill invocation when the harness supports nested skills. Otherwise, read the sibling skill file and execute its workflow directly. Do not send a slash command to a shell or UI.

After `ship` succeeds, record the pull request branch and current worktree:

```bash
branch=$(git branch --show-current)
worktree=$(git rev-parse --show-toplevel)
```

Stop if the branch is empty or is the default branch.

## 2. Pass

Load `../pr-pass/SKILL.md` and execute its full workflow for the pull request from phase 1.

If checks remain failed or pending, or `pr-pass` reports a blocker, stop. Keep the local branch and worktree so later work can continue.

## 3. Burn

Confirm that no local work can be lost:

```bash
test -z "$(git status --porcelain)"
git merge-base --is-ancestor HEAD "origin/$branch"
```

Stop if either command fails.

Find the primary worktree:

```bash
primary=$(git worktree list --porcelain | sed -n 's/^worktree //p' | head -n1)
```

If `$worktree` is not the primary worktree, move to `$primary`, then remove the feature worktree and force-delete its unmerged local branch:

```bash
cd "$primary"
wt del -- --foreground "$branch"
```

`wt del` includes branch deletion. Its force-delete behavior is required because the pull request is still open and the branch commits exist on the remote.

If `$worktree` is the primary worktree, check out the default branch and delete only the local feature branch. Never remove the primary worktree:

```bash
git checkout "<default>"
git branch -D "$branch"
```

Do not delete the remote branch or pull request.

Report the pull request URL, green check state, deleted local branch, and deleted worktree path. For a primary worktree, report that it was kept.
