---
name: gha
description: Analyze a GitHub Actions failure and identify the root cause. Use whenever the user pastes a GitHub Actions run URL, says "/gha", asks "why did CI fail", "what broke the build", "this workflow is failing", "which commit broke CI", or wants a failing Actions run investigated — even without the word "GitHub Actions".
argument-hint: "<url>"
---

Investigate this GitHub Actions URL: $ARGUMENTS

Use the gh CLI to analyze this workflow run. Your investigation should:

1. **Get basic info & identify the failure**:
   - What workflow/job failed, when, and on which commit?
   - Read the full logs to find what specifically produced the non-zero exit. CI output is noisy —
     a job often prints many red-looking lines (warnings, retries, "non-fatal" notices) that didn't
     actually fail it. The goal is the *one* thing that did, so the rest of the investigation
     doesn't chase a red herring.
   - Look for the signal that marks the real failure: patterns like "failing:", "fatal:", `Error:`
     annotations, or the script logic that decides when to `exit 1`.
   - When both "non-fatal" and "fatal" errors appear, trace which one actually stopped the job.

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
   - Tie the cause back to the specific failure trigger from step 1, not to incidental errors.
   - Verify the hypothesis against the logs and failure logic before reporting it — a plausible
     guess that the logs don't actually support is worse than saying "couldn't determine".

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
