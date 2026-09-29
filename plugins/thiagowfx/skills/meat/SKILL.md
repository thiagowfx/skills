---
name: meat
description: Create a fast reading guide for a code change without performing a findings-based review. Use when the user says "abridge this diff", "explain this diff or PR", "give me a reading guide", "help me understand this change", or wants important behavior and data flow without mechanical noise. Optionally post the guide to the target pull request.
argument-hint: "[PR-URL|PR-NUMBER|REVISION|RANGE|branch|staged|unstaged|all] [--post]"
model: haiku
---

# Meat

Turn a change into a compact reading guide for a senior engineer: what changed, where data came from, where it went, and what behavior appeared. Do not invoke external summarizers, another model, reviewers, or a numbered edit-plan loop.

This is code comprehension, not defect finding. Do not report findings, severities, suggestions, approval verdicts, or style feedback. If the user wants correctness review, use `dual-review` instead.

## Arguments

Parse `$ARGUMENTS` or the user's natural-language target:

- `--post`: post the final reading guide to the target pull request after showing it. An explicit natural-language request to comment on the PR also authorizes posting; never post otherwise.

Reject unknown arguments instead of guessing. Posting requires a target PR (explicit or resolved from the current branch). Reject posting for revision, range, `staged`, `unstaged`, `all`, or a branch without a PR.

## Resolve Scope

Resolve the target:

- PR URL or number: fetch title, body, base/head SHAs, and changed files with `gh pr view`; capture the diff once with `gh pr diff`. Never check out the PR.
- `branch`: diff the current branch from its PR base when one exists; otherwise use the verified remote default branch and its merge base.
- revision or commit: `git show --find-renames <revision>`.
- range (`A..B` or `A...B`): `git diff --find-renames <range>`.
- `staged`: `git diff --cached --find-renames`.
- `unstaged`: `git diff --find-renames`.
- `all`: staged, unstaged, and untracked files from the current checkout.
With no explicit target, use this order:

1. Current branch's open PR, if one exists; use the PR scope above.
2. If there is no open PR and the current branch is not the verified default branch, use `branch` scope.
3. If on the default branch without an open PR, use `staged` scope.

Explicit targets override this order. Do not substitute `HEAD`, unstaged changes, or untracked files when the selected scope is empty;
report that there are no changes in that scope. Verify the default branch from the remote rather than guessing its name.
Keep local changes outside the selected scope excluded.

When posting is requested, resolve and record the target PR number and URL before reading the change.

Confirm repository and scope contain changes. Record exact scope and complete changed-file list. Never switch, reset, merge, or mutate the checkout.
Read surrounding source only when the diff leaves a load-bearing contract ambiguous; for another revision, prefer
`git show <revision>:<path>` over checkout.

Capture the diff once to a temporary file when needed. Inspect that file in bounded chunks; do not repeatedly inject the full diff into context.
For large changes, classify files first and read behavior-bearing files in dependency order. Skip generated files after verifying a generated header or established generated path.

## Distill

Make one synthesis pass. Keep only evidence needed to understand:

1. Changed public contract, entry point, schema, or configuration.
2. New condition, branch, lifecycle edge, precedence rule, or failure path.
3. Non-obvious transformation, lookup, state mutation, or dispatch.
4. Observable effect: return, response, persisted state, emitted event, or external call.
5. Compatibility, security, migration, or rollout invariant explained by code or comments.
6. Tests as specifications: distinctive stimulus and expected outcome for each behavior dimension.

Collapse repeated call sites, fixtures, assertion batches, obvious field plumbing, imports, formatting, lockfiles, generated output, and mechanical renames. Mention omitted categories rather than silently dropping them. Treat exact moves as moves, not deletion plus addition.

Use only source-backed names and behavior. Distinguish enforced behavior from comments or PR claims; label an unverified compatibility or rollout claim as
`Assumption:`. Quote exact changed lines when useful; never invent replacement code or prose inside a code snippet. Keep at most four snippets, each no more than six
lines. Prefer complete `path:line` anchors over snippets when code is already obvious. Call unit tests unit tests; do not upgrade mocked coverage to integration or
end-to-end coverage.

## Output

Default to 300 words or fewer. Expand only when change contains independent subsystems.

1. One sentence stating intent and observable result.
2. `## Read in this order`: three to five complete `path:line` anchors, each explaining why it is load-bearing. Follow actual control/data flow rather than diff order.
3. `## Flow`: three to six concise numbered steps from input through transformation to effect. Include failure/skip branch only when behaviorally distinct.
4. `## Contracts`: at most three changed invariants, compatibility boundaries, or explicitly labeled assumptions. Omit section when empty.
5. `## Tests as specs`: scenario → expected outcome. Omit repetitive setup and identify test level accurately.
6. `## Omitted`: one line naming generated/mechanical categories skipped and accounting for every changed file not otherwise mentioned.

No preamble, review verdict, recommendations, or trailing summary. Finish after first complete reading guide; do not run a second refinement pass.

Show the final reading guide in chat. Post only when the user explicitly requested `--post` or clearly asked for a PR comment. Use a body file rather than shell-interpolating Markdown. Report the PR comment URL after a successful post.
