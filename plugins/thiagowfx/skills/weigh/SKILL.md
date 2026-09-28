---
name: weigh
description: Decide whether a proposed or implemented change is worth adopting. Use when the user says "/weigh", "/justify", "justify this change", "is this worth it", "should we keep this", or asks for pros and cons, costs and benefits, or a go/no-go recommendation on a change. Compare against the status quo and realistic alternatives; do not edit code.
argument-hint: "[PR-URL|PR-NUMBER|REVISION|RANGE|branch|staged|all|proposal]"
---

# Weigh

Make a decision about adopting a change, not a correctness verdict or a defense of work already done. The outcome may be **adopt**, **revise**, **reject**, or **defer**. Stay read-only: do not edit, commit, post, or push.

## Select the change

Use an explicit user target first. Accept a PR URL or number, revision or range, `branch`, `staged`, `all`, or a proposal described in the conversation. Reject ambiguous or conflicting targets. With no explicit target, use this order:

1. Current branch's open PR, if one exists.
2. `branch`, if there is no open PR and the current branch is not the verified default branch.
3. `staged`, if on the default branch without an open PR.

Explicit targets and proposals override this order. Verify the remote default branch rather than guessing its name.
If the selected scope contains no change, ask for a change or proposal; do not substitute `HEAD`, unstaged changes, or untracked files.
Identify local changes outside selected scope as excluded.

Record the exact scope and baseline:

- PR: read title, body, base/head SHAs, changed files, and diff without changing checkout.
- Branch: use the PR base if available; otherwise verify the default branch and use its merge base. Include local commits that differ from the PR head.
- Revision/range: preserve the supplied comparison, including its parent/base semantics.
- `staged`: inspect staged diff and file list. `all`: inspect staged, unstaged, and untracked content; do not rely on `git diff` alone.
- Proposal: state the proposed behavior and the current behavior from user context or repository evidence. Label assumptions.

Read behavior-bearing changes and relevant callers, tests, documentation, or history to understand intent and effects.
Check for local changes outside selected scope and identify them as excluded.
If the target is too large, first group it by independently adoptable decisions; do not give one verdict for unrelated changes.

## Compare options

Compare **adopt as-is**, **keep current behavior**, and at least one plausible smaller or different approach when one exists. Evaluate only dimensions that matter for this change:

- User or operator benefit: what concrete problem it solves and who receives the benefit.
- Costs: implementation and ongoing maintenance, new dependencies, complexity, migration, rollout, and support.
- Downsides: regressions, compatibility, security, performance, operational risk, and lost functionality.
- Reversibility: cost to undo, data or API commitments, and cost of waiting.
- Evidence: tests, observed behavior, usage, measurements, and requirements. Distinguish demonstrated facts from inferred effects or assumptions; do not invent quantities or claim a test proves adoption value.

Treat time already spent as sunk cost. Ask whether the benefit exceeds the **future** cost and risk relative to the best alternative.
Avoid counting the same benefit or cost twice. Do not praise a change for existing merely because it is implemented.
State what would change your decision if material evidence is missing. If correctness is disputed, identify the specific risk;
do not claim to have completed a full code review or verification unless you did so.

## Report

Lead with `Recommendation: ADOPT | REVISE | REJECT | DEFER` and one sentence explaining why. Then give concise bullets:

- **Upside:** strongest concrete benefit, with evidence.
- **Downside:** strongest concrete future cost or risk, with evidence.
- **Alternatives:** status quo and best feasible alternative, with reasons each wins or loses.
- **Decision condition:** smallest change or missing fact that would reverse or confirm the recommendation; omit if not needed.

Cite `path:line`, test results, PR text, or user requirements for material claims. Label unverified assumptions.
If recommending `REVISE`, say exactly what to change. If recommending `DEFER`, identify the missing evidence and how to get it.
Keep the report proportional to the decision. Do not edit code or start another skill unless asked.
