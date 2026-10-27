---
name: review
description: Full-stack review of a diff. Fans out in parallel to `review-spec` (does the code match the spec?), `review-correctness` (what breaks?), `review-security` (what can an attacker do?), `review-lazy` (what can we delete?), and `review-abstraction` (do new seams earn their keep?). Aggregates a single report. Use when the user says "review this", "review the diff", "review my branch", "review the PR".
license: MIT
---

# Review — orchestrator

Run the five specialist reviewers in parallel forks against the same diff, aggregate their outputs, and print one report.

## Inputs

1. **Diff range**: default `git diff <merge-base>...HEAD`. Accept user-supplied range or pasted diff. If not in a git repo, ask.
2. **Spec path**: default `~/.claude/specs/<repo>/<slug>.md`, where `<repo>` is the basename of `git rev-parse --show-toplevel`, if only one exists (ignore `*.state.md`, `*.digest.md` and `*.verify.md`, which `/mattstack:run` keeps alongside); if several exist, use the one whose slug matches the current branch name; else ask which. If no spec exists at all, skip `review-spec` and note the omission in the report.

## Fan-out

Spawn five parallel sub-agents (one per specialist skill). Each gets the same diff (and the spec path, for `review-spec`). Wait for all five to return.

- Fork 1 → invoke `/mattstack:review-spec`
- Fork 2 → invoke `/mattstack:review-correctness`
- Fork 3 → invoke `/mattstack:review-security`
- Fork 4 → invoke `/mattstack:review-lazy`
- Fork 5 → invoke `/mattstack:review-abstraction`

Fan-out uses parallel tool calls in one message. Do not run serially — the whole point of the orchestrator is wall-clock speed.

## Aggregated report

Print in this order:

```
## Review — <branch or range>

### Spec conformance
<verbatim output from review-spec, or "skipped: no spec found">

### Correctness
<verbatim output from review-correctness>

### Security
<verbatim output from review-security>

### Laziness
<verbatim output from review-lazy>

### Abstraction cost
<verbatim output from review-abstraction>

### Verdict

<one line, per rules below>
```

## Verdict rule

- Any `critical` from `review-spec`, `review-correctness` or `review-security`, or any `violates` → `verdict: block. Fix critical findings before merge.`
- Any `major` from `review-spec`, `review-correctness` or `review-security`, OR a `net -N` from `review-lazy` where N is more than 20% of added lines → `verdict: revise. <one-line summary of the top pressure>.`
- Otherwise → `verdict: ship.`

## Boundaries

Does not apply fixes. Deduplication is not needed: each specialist has a distinct scope, so a finding from two of them is signal, not noise.
