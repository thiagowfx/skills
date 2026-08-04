---
name: pr-pass
description: Use when asked to "/pr-pass", "fix CI", "make checks green", or "loop until CI passes", or when GitHub pull request checks are failing or pending.
---

# PR Pass — Push and Fix Until Green

Push current branch, watch its existing pull request checks, fix failures, and repeat until checks pass or five fix-and-push passes complete.

## Loop Strategy

Execute the full loop directly in the current skill invocation.

If the harness explicitly says a goal or continuation is already active and exposes callable tools for it, follow that active mechanism's tool contract.
Never try to start a UI command such as `/goal`, invoke it through a skill tool (for example, `Skill(goal)`), or ask the user to start one.
UI commands are entrypoints, not nested skills.

Do not guess command or tool names. Workflow must work when the harness provides only shell and file-editing tools.

## Workflow

### 1. Push Branch

Run:

```bash
git push
```

If branch has no upstream, run:

```bash
git push -u origin "$(git branch --show-current)"
```

### 2. Find Existing Pull Request

Run:

```bash
gh pr view --json url,number,headRefName
```

If no pull request exists, stop and report that one must be created first. Do not create it.

### 3. Inspect Checks

Run once per pass:

```bash
gh pr checks <number> --json name,state,bucket,link
```

- All buckets are `pass` or `skipping`: report success and stop.
- Any bucket is `fail` or `cancel`: diagnose surfaced failures immediately.
- Checks are only `pending`, `pass`, or `skipping`: wait with GitHub CLI, then inspect checks again:

  ```bash
  gh pr checks <number> --watch --fail-fast
  ```

`--watch` and `--json` are mutually exclusive. Never combine them.

### 4. Diagnose and Fix

For each failed workflow run, extract run ID from check link and inspect failed logs:

```bash
gh run view <run-id> --log-failed
```

Identify root cause. Check recent runs before classifying failure as flaky. For real code failures:

1. Fix code.
2. Run relevant local tests, lint, type checks, or build through caller path.
3. Commit fix with clear message.
4. Push and begin next pass.

If failure is flaky, rerun failed workflow jobs with `gh run rerun <run-id> --failed`, then inspect checks again. If failure comes from infrastructure, permissions, or external service, report blocker and stop.

### 5. Enforce Limit

One pass is one inspect → diagnose/fix → push cycle. Stop after five passes and report remaining failures.

## Completion Report

Include pull request URL, final check state, passes used, and any unresolved blocker.
