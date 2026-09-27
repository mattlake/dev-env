---
name: review-spec
description: Check a diff against a spec doc — does the code deliver every behaviour, honour every constraint, respect every non-goal? One line per finding, tagged and severity-ranked. Use when the user says "review against spec", "spec check", "does this match the spec", or when `/mattstack:review` fans out.
license: MIT
---

# Review — spec conformance

Compare a diff to a spec doc. One question per finding: does the code deliver what the spec asked for, no more, no less?

## Inputs

1. **Spec path**: `~/.claude/specs/<repo>/<slug>.md` (or supplied by the user or by `/mattstack:review`).
2. **Diff**: default is `git diff <merge-base>...HEAD`. If the user supplies a range, use it. If not in a git repo, ask.

If the spec is missing, stop and tell the user.

## Format

One line per finding: `<file>:L<line>: <tag> <severity>: <what>. <fix>.`

Tags:

- `missing:` a spec behaviour has no code delivering it.
- `partial:` a spec behaviour is implemented for some cases, not all.
- `drift:` code delivers something the spec did not ask for (scope creep).
- `violates:` code breaks a stated constraint or non-goal.
- `undertested:` behaviour exists in code but no test would fail if it broke.

Severities:

- `critical:` a behaviour is missing, a constraint is violated, or a non-goal is crossed. Blocks merge.
- `major:` a behaviour is partial or undertested such that a plausible regression would ship.
- `minor:` drift that is harmless but noted for the record.

Order findings: critical first, then major, then minor. Group by tag inside each severity band.

## Examples

`src/auth/session.ts:L42: missing critical: spec B3 (session timeout after 15m idle) not implemented. Add idle timer + logout.`

`src/checkout.py:L120-138: partial major: spec B7 (retry on 5xx) only retries on 500, not 502/503/504. Widen the predicate.`

`src/api/routes.ts:L88: drift minor: adds /admin/purge endpoint not in spec. Confirm scope or remove.`

`package.json:L23: violates critical: spec constraint C2 says "no new runtime deps"; adds lodash. Use stdlib equivalents.`

`src/user.py:L55: undertested major: spec B2 (unique email) has no test covering the duplicate case. Add one.`

## End line

Print exactly one summary line after all findings:

```
spec: <critical> critical, <major> major, <minor> minor. <B_covered>/<B_total> behaviours covered.
```

If zero findings at any severity: `spec: matches. <N>/<N> behaviours covered. Ship.`

## Boundaries

Scope: spec conformance only. Bugs unrelated to the spec, security holes, and performance are out of scope — that is what `/mattstack:review-lazy` and a normal review pass are for. Do not apply fixes; only list them.
