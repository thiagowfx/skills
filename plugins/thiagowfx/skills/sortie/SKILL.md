---
name: sortie
description: Independently verify that a working tree, staged diff, commit, branch, or pull request is correct before completion or merge. Use when the user says "sortie", "verify", "verify this change/commit/PR", "is this correct", "is this ready", "prove it works", "check the implementation", "validate against requirements", or asks for final acceptance. Reconstruct intent, inspect the complete change and its tests, run caller-level success, failure, skip, and regression paths, run relevant repository gates, and report PASS, FAIL, or INCONCLUSIVE with evidence. Do not change code.
argument-hint: "[PR-URL|PR-NUMBER|REVISION|RANGE|branch|staged|all] [--against ISSUE-URL|SPEC-PATH]"
---

# Sortie

Prove that selected change implements intended behavior and does not break required behavior. Verification is read-only. Findings lead to a report, not edits.

## Parse Arguments

Accept one target and optional `--against` source:

- PR URL or number
- revision, commit, or revision range
- `branch`: current branch from merge base with PR base or verified default branch
- `staged`: staged changes only
- `all`: staged, unstaged, and untracked working-tree changes
- `--against <source>`: issue URL, specification path, plan path, or other acceptance source

Reject unknown or conflicting arguments.

When no target is supplied, use this order:

1. Current branch's open PR, if one exists.
2. `all`, if current checkout has local changes.
3. Current branch against its verified default-branch merge base, if branch is ahead.
4. `HEAD`, for a clean default branch.

## 1. Freeze Scope

Resolve target without changing user's checkout.

- PR: record repository, number, URL, base SHA, head SHA, title, body, changed files, checks, and review state. Do not check out PR over user work.
- Branch: record merge base, head SHA, and complete three-dot diff.
- Commit: review exact commit and every parent needed to interpret it. State parent selected for merge commit.
- Range: preserve range semantics supplied by user.
- `staged`: capture `git diff --cached` and staged file list.
- `all`: capture staged, unstaged, and untracked content.

Record target identity and content fingerprint. Include untracked content when in scope. Capture complete diff once and inspect it in bounded chunks. Stop if target cannot resolve or contains no changes.

If another checkout is required, use existing matching worktree or isolated temporary worktree. Never switch, reset, merge, or rebase user's checkout. Clean up only temporary worktree created for this run.

## 2. Reconstruct Intent

Find authoritative intent in this order:

1. Explicit user requirements and `--against` source.
2. Linked issue, accepted specification, or plan.
3. PR title and body.
4. Commit messages and repository design documents.
5. Behavior inferred from changed callers and tests.

Extract atomic claims. Each claim must describe observable behavior, required failure behavior, compatibility constraint, or explicit non-goal. Mark inferred claims as `INFERRED`.

Build evidence matrix before execution:

| Claim | Required evidence | Planned check |
| --- | --- | --- |
| Observable behavior | Caller-visible result | Focused execution |
| Failure behavior | Expected error and absence of side effect | Negative-path execution |
| Skip or no-op behavior | Unchanged state and reason | Skip-path execution |
| Compatibility | Existing caller or serialized contract remains valid | Contract check and regression test |
| Non-functional requirement | Measured threshold | Measurement |

If material product intent cannot be reconstructed, continue technical verification but final verdict cannot be `PASS`.

## 3. Inspect Change and Tests

Read every changed file. Read surrounding callers, callees, schemas, configuration, generated surfaces, tests, and documentation needed to trace each claim.

Check:

- every claim reaches real entry point and observable effect;
- success, failure, skip, retry, cleanup, and repeated-call paths affected by change;
- defaults, missing values, invalid values, and compatibility behavior;
- auth, authorization, data integrity, persistence, concurrency, and lifecycle boundaries when touched;
- all callers when signature, default, schema, wire value, or public contract changes;
- scope creep and required adjacent updates;
- test assertions exercise intent instead of implementation shape;
- mocks do not bypass logic under test;
- expected values come from known-good behavior, not code under test;
- no disabled, weakened, tautological, or catch-all-success tests hide failures.

For non-trivial changes, use fresh independent review context when harness supports it.
Give reviewer exact scope, intent matrix, complete diff, and relevant repository instructions.
Keep reviewer read-only. Ask for concrete failure scenarios and exact locations.
Validate every candidate against source before accepting it.
If independent context is unavailable, report that limitation; do not label same-context review independent.

## 4. Design Verification

Discover project-native commands from repository instructions, CI workflows, task runners, package scripts, and nearby tests. Do not invent generic commands when repository defines canonical ones.

Choose checks that directly prove claims:

1. Focused test or deterministic probe for changed behavior.
2. Real caller path through CLI, API, UI, service, loader, or consumer import.
3. Failure and skip paths affected by change.
4. Relevant integration or end-to-end boundary.
5. Type, schema, generated-surface, migration, package, build, lint, and format checks affected by change.
6. Broader repository gates after focused checks pass and target is stable.

Match depth to risk. Shared utilities, auth, payments, migrations, persistence, concurrency, build tooling, serialization, permissions, and public contracts require broader checks.

For hostile input boundaries, include relevant empty, malformed, repeated, missing-dependency, and shell-sensitive inputs. Exercise backticks, `$`, and unbalanced quotes when values cross shell or template layers.

Do not treat these as proof of behavior:

- code inspection alone;
- typecheck or build alone;
- test names without reading assertions;
- CI status without confirming tested SHA and coverage;
- previous command output;
- agent or tool success report;
- truncated output or pipeline status that hides command exit status.

State expensive plan before execution. Explain skipped checks.

## 5. Execute and Validate Evidence

Run focused checks first. Read full output and exit status. Confirm observed result matches expected result, not only exit code.

Exercise every changed decision path independently:

- success;
- expected failure;
- skip or no-op;
- retry, repeated call, cleanup, or rollback when applicable.

For bug fixes:

1. Observe original symptom against baseline when practical.
2. Verify symptom against target.
3. Run regression test against target.
4. In isolated checkout, prove regression test fails when fix is absent and passes when present.

For configuration or data writes, read effective destination state after operation. Tool output that says write succeeded is not destination evidence.

If a check changes tracked or in-scope untracked content, capture new fingerprint, explain mutation, and rerun affected review and checks against new stable target. Do not combine evidence from different fingerprints.

Classify each result:

- `VERIFIED`: direct current evidence proves claim.
- `FAILED`: evidence contradicts claim or shows regression.
- `UNVERIFIED`: required evidence could not be obtained.
- `NOT APPLICABLE`: claim does not apply, with reason.

Do not use confidence scores. Evidence quality determines status.

## 6. Recheck Target

After all checks, recalculate target identity and content fingerprint.

- If unchanged, evidence applies to target.
- If changed, discard stale evidence and verify new target.
- If PR head advanced, report old and new SHAs and restart against new head.

For PR scope, confirm CI and review state again. CI supplements local evidence; it does not replace caller-level verification.

## Verdict

Return exactly one verdict:

- `PASS`: every required claim is `VERIFIED`, relevant repository gates pass, target is stable, and no material review finding remains.
- `FAIL`: at least one required claim is false, target introduces material defect, or target causes required check to fail.
- `INCONCLUSIVE`: no failure was proved, but intent, environment, independence, target stability, or required evidence is missing.

Unrelated baseline failures do not prove target failure. Identify them with evidence. If they block required proof, verdict is `INCONCLUSIVE`, not `PASS`.

## Output

```markdown
## Verdict: PASS | FAIL | INCONCLUSIVE

Target: <scope and immutable identity>
Intent: <sources>
Fingerprint stable: yes | no

## Claim evidence
| Claim | Status | Evidence |
| --- | --- | --- |
| ... | VERIFIED / FAILED / UNVERIFIED | command, observation, or path:line |

## Findings
- [severity] `path:line` — failure scenario and impact

## Commands
- `command` — PASS / FAIL — decisive output

## Unverified
- missing evidence and reason
```

Omit empty `Findings` and `Unverified` sections. Never claim merge readiness beyond evidence. Do not post, approve, comment, edit, commit, push, or merge unless user explicitly requests separate action.
