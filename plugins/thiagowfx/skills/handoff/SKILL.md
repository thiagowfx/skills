---
name: handoff
description: Create a portable handoff document for another agent or harness to continue current work. Use when the user asks for a handoff, continuation brief, or context transfer.
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
source: https://github.com/mattpocock/skills (skills/productivity/handoff, MIT © Matt Pocock)
---

Write a self-contained handoff document for a fresh agent in any harness. Save it with a unique filename in the user's OS temporary directory, never current workspace. In your final response, give its absolute path.

Use this structure:

```markdown
# Handoff

## Goal

## Context

## Current state

## Decisions and findings

## Relevant artifacts

## Next task

## Validation

## Suggested skills
```

Include only context needed to continue: relevant decisions, findings, file paths, current status, verification completed or still needed, and clear next task. If user passed arguments, use them as next-session goal; otherwise infer goal from conversation.

Do not duplicate content already captured in artifacts such as PRDs, plans, ADRs, issues, commits, or diffs. Reference those by path or URL, while summarizing context needed to understand them.

Redact sensitive information, including API keys, passwords, and personally identifiable information.
