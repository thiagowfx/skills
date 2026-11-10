---
name: find-ready-prs
description: Find the user's open pull requests that are ready to merge, without merging them. Use whenever the user says "/find-ready-prs", "which PRs are ready", "find PRs ready to merge", "what can I merge", or wants to know which of their open PRs are green and approved.
model: sonnet
allowed-tools: Bash(gh search prs:*), Bash(gh pr view:*), Bash(gh pr list:*), Bash(gh repo view:*), Bash(git remote:*)
---

List open PRs authored by the user that are ready to merge. Read-only: never merge, approve, or edit anything.

## Instructions

1. **Scope.** If inside a git repo and the user asked about "this repo", use `gh pr list --author @me --state open -R <repo>`. Otherwise search everywhere: `gh search prs --author @me --state open --limit 100 --json url,title,repository,isDraft`. If the user uses a non-default GitHub host, honor `GH_HOST`.
2. **Skip drafts** (`isDraft: true`).
3. **Inspect each remaining PR** with `gh pr view <number> -R <owner/repo> --json reviewDecision,mergeStateStatus,mergeable,statusCheckRollup`. Run these in parallel or in a background job; there can be many.
4. **Check merge permission** once per distinct repo: `gh repo view <owner/repo> --json viewerPermission -q .viewerPermission`. The user can merge only if it is `WRITE`, `MAINTAIN`, or `ADMIN`. `READ` and `TRIAGE` mean the user cannot merge.
5. **Count failures and pending checks** from `statusCheckRollup`:
   - failed: `conclusion` is `FAILURE`, or `state` is `FAILURE` or `ERROR`
   - pending: `state` is `PENDING`, or `status` is `IN_PROGRESS` or `QUEUED`
6. **Classify:**
   - If the user cannot merge (step 4), never classify the PR as Ready or Close. Put it under **Cannot merge** with its permission level, even if it is green and approved.
   - **Ready (approved)**: `reviewDecision` is `APPROVED`, `mergeStateStatus` is `CLEAN`, no failed or pending checks.
   - **Ready (no review required)**: `reviewDecision` is empty, `mergeStateStatus` is `CLEAN`, no failed or pending checks. Say that the repo requires no review.
   - **Close**: approved and `mergeable`, but `mergeStateStatus` is `UNSTABLE` (a non-required check fails). Name the failing check.
   - **Not ready**: review required, `BLOCKED`, `DIRTY`/conflicts, failed or pending checks.
   - **Unknown**: `mergeStateStatus` is `UNKNOWN`. GitHub has not computed it yet; suggest re-checking later.
7. **Report** as short lists with clickable PR links and titles: Ready first, then Close, then a one-line summary of Cannot merge, Not ready, and Unknown. Keep the keyed `owner/repo#number` form.

## Rules

- Never run `gh pr merge`, `gh pr review`, or any command that changes state.
- Map results to PRs by URL, not by output order, when running in parallel.
