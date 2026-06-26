---
name: gha
description: Analyze GitHub Actions failures and identify root causes
argument-hint: "<url>"
---

Investigate this GitHub Actions URL: $ARGUMENTS

Use the gh CLI to analyze this workflow run. Your investigation should:

1. **Get basic info & identify actual failure**:
   - What workflow/job failed, when, and on which commit?
   - CRITICAL: Read the full logs carefully to find what SPECIFICALLY caused the exit code 1
   - Distinguish between warnings/non-fatal errors vs actual failures
   - Look for patterns like "failing:", "fatal:", or script logic that determines when to exit 1
   - If you see both "non-fatal" and "fatal" errors, focus on what actually caused the failure

2. **Check flakiness**: Check the past 10-20 runs of the exact same failing job:
    - If a workflow has multiple jobs, check history for the specific job that failed, not just the workflow
    - Use `gh run list --workflow=<workflow-name>` to get run IDs, then `gh run view <run-id>
      --json jobs` to check the specific job's status
    - Is this a one-time failure or recurring pattern for this job?
    - What's the success rate recently? When did it last pass?

3. **Identify breaking commit** (if there's a pattern of failures for the specific job):
   - Find the first run where this job failed and the last run where it passed
   - Identify the commit that introduced the failure
   - Verify: does the job fail in all runs after that commit and pass in all before?
   - If verified, report the breaking commit with high confidence

4. **Root cause**: Based on logs, history, and any breaking commit, what's the likely cause?
   - Focus on what ACTUALLY caused the failure (not just any errors you see)
   - Verify your hypothesis against the logs and failure logic

5. **Check for existing fix PRs**: Search for open PRs that might already address this issue:
   - Use `gh pr list --state open --search "<keywords>"` with relevant error messages or file names
   - Check if any open PR modifies the failing file/workflow
   - If a fix PR exists, note it in your report and skip the recommendation section

Write a final report with:

- Summary of failure (what specifically triggered the exit code 1)
- Flakiness assessment (one-time vs recurring, success rate)
- Breaking commit (if identified and verified)
- Root cause analysis (based on the actual failure trigger)
- Existing fix PR (if found — include PR number and link)
- Recommendation (skip if fix PR already exists)
