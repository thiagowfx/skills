---
name: pr-pass
description: Push, watch CI, fix failures as they complete, and loop until all checks pass. Use when asked to "/pr-pass", "fix CI", "make checks green", or "loop until CI passes".
---

# PR Pass — Push and Fix Until Green

Push your code, then let `/goal` re-drive each turn: check CI, fix a failure, push, repeat until every check passes.

## How this works

This skill delegates the loop to the built-in
[`/goal`](https://code.claude.com/docs/en/goal) command (Claude Code
v2.1.139+). Instead of a hand-rolled iteration counter and a `Monitor` poll,
you set one completion condition; after each turn a fast model checks whether
CI is green and, if not, starts another turn. The goal auto-clears once it
holds.

Two consequences shape the steps below:

- **The evaluator only reads the transcript** — it does not run `gh` or read files. So every turn must *surface the current CI state in your output* (paste the `gh pr checks` result) for the evaluator to judge against.
- **Each turn does one pass, then ends** — check state, fix at most the failures that have surfaced, push. Do not loop inside a turn; `/goal` restarts you.

## Instructions

### Step 1: Set the goal

Before touching CI, set the completion condition. This starts the loop immediately:

```text
/goal every check on this PR has passed (gh pr checks shows no FAILURE and no PENDING), or stop after 5 turns
```

The `or stop after 5 turns` clause replaces the old max-5-iterations guard. If the session is unattended, the user should pair this with auto mode — `/goal` does not change permissions, so `git push` / `gh` calls still prompt otherwise.

### Step 2: Push

- Run `git push` to push the current branch.
- If no upstream is set, run `git push -u origin $(git branch --show-current)`.

### Step 3: Find the PR

- Run `gh pr view --json url,number,headRefName` to find the PR for this branch.
- If no PR exists, stop and tell the user to create one first (e.g., `/send-pr`). Clear the goal with `/goal clear` — there is nothing to loop on.

### Step 4: Check CI once and surface it

Run a single check and **include its output in your reply** so the goal evaluator can see it:

```bash
gh pr checks <number> --json name,state,bucket,link
```

- If all checks completed (no `"state": "PENDING"`) and all passed — report success. The goal condition now holds and auto-clears.
- If any check is `"state": "FAILURE"` — go to Step 5 for those failures.
- If checks are still `PENDING` and none failed — say so and end the turn. `/goal` re-runs after the evaluator; on the next turn the state will have advanced. Do not `sleep` or `Monitor`-poll inside the turn; the loop is external now.

### Step 5: Analyze and fix the failures that have surfaced

For each failed check:

```bash
gh run view <run-id> --log-failed
```

- Identify the root cause (test failure, lint error, build error, type error, etc.).
- Distinguish flaky from real by checking whether the same test passed in recent runs.
- Fix the issue in the code.
- Run relevant local checks (tests, lint, build) to verify before pushing.
- Commit with a clear message describing the fix.

Then end the turn. Step 2 (push) runs at the top of the next turn that `/goal` starts.

## Notes

- If a test passes locally and has an intermittent history on main, push without changes to retry CI — the next goal turn re-checks.
- If a failure is in infrastructure (CI config, permissions, external service), report it and run `/goal clear` rather than burning turns.
- Always run local verification before pushing to avoid wasting CI cycles.
- To stop early at any point, run `/goal clear`. To see turns/tokens spent, run `/goal` with no argument.
