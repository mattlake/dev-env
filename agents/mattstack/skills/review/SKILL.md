---
name: review
description: Full-stack review of a diff. Fans out in parallel to `review-spec` (does the code match the spec?), `review-lazy` (what can we delete?), and `review-abstraction` (do new seams earn their keep?). Aggregates a single report. Use when the user says "review this", "review the diff", "review my branch", "review the PR".
license: MIT
---

# Review — orchestrator

Run the three specialist reviewers in parallel forks against the same diff, aggregate their outputs, and print one report.

## Inputs

1. **Diff range**: default `git diff <merge-base>...HEAD`. Accept user-supplied range or pasted diff. If not in a git repo, ask.
2. **Spec path**: default `./specs/<slug>.md` if only one exists; else ask which. If no spec exists at all, skip `review-spec` and note the omission in the report.

## Fan-out

Spawn three parallel sub-agents (one per specialist skill). Each gets the same diff (and the spec path, for `review-spec`). Wait for all three to return.

- Fork 1 → invoke `/mattstack:review-spec`
- Fork 2 → invoke `/mattstack:review-lazy`
- Fork 3 → invoke `/mattstack:review-abstraction`

Fan-out uses parallel tool calls in one message. Do not run serially — the whole point of the orchestrator is wall-clock speed.

## Aggregated report

Print in this order:

```
## Review — <branch or range>

### Spec conformance
<verbatim output from review-spec, or "skipped: no spec found">

### Laziness
<verbatim output from review-lazy>

### Abstraction cost
<verbatim output from review-abstraction>

### Verdict

<one line, per rules below>
```

## Verdict rule

- Any `critical` from `review-spec` OR any `violates` from any specialist → `verdict: block. Fix critical findings before merge.`
- Any `major` from `review-spec` OR a `net -N` from `review-lazy` where N is more than 20% of added lines → `verdict: revise. <one-line summary of the top pressure>.`
- Otherwise → `verdict: ship.`

## Boundaries

Does not apply fixes. Does not re-run correctness or security checks — pair with the appropriate specialist for those. Deduplication is not needed: each specialist has a distinct scope, so a finding from two of them is signal, not noise.
