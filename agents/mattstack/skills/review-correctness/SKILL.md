---
name: review-correctness
description: Bug hunt on a diff — wrong results, crashes, races, leaks, missed edge cases, swallowed errors. Every finding names the concrete input or state that triggers it. One line per finding, tagged and severity-ranked. Use when the user says "find bugs", "correctness review", "is this right", "what breaks", or when `/mattstack:review` fans out.
license: MIT
---

# Review — correctness

Find the inputs and states under which the diff does the wrong thing. A finding without a trigger is a guess, not a finding.

## Inputs

Default: `git diff <merge-base>...HEAD`. User can supply a range or paste a diff. If not in a git repo, ask.

Read beyond the diff where the diff reaches: callers of changed functions, the types they pass, the state they share. A change that is correct in isolation can break a caller.

## Format

`<file>:L<line>: <tag> <severity>: <what goes wrong>. Trigger: <input or state>. <fix>.`

Tags:

- `bug:` returns or stores the wrong result.
- `crash:` unhandled error, panic, null or undefined dereference, out-of-range access.
- `race:` result depends on timing between threads, requests, or async steps.
- `leak:` file, connection, lock, listener, timer or goroutine not released on some path.
- `edge:` breaks at a boundary: empty, zero, negative, max size, unicode, timezone, DST, off-by-one.
- `swallow:` error caught and dropped, so failure looks like success.

Severities:

- `critical:` wrong data stored, data lost, or a crash, on a path normal use reaches.
- `major:` triggered by a plausible input or state, but not the main path.
- `minor:` triggered only by unusual input, and the damage is contained.

Order findings critical first, then major, then minor.

## Check before reporting

For each candidate, prove the trigger reaches the line: follow the call path from an entry point, check the types, check for a guard upstream. Where cheap, run it: a throwaway script or test in a temp directory outside the repo that feeds the trigger and shows the wrong result. Delete nothing and edit nothing in the repo.

If you cannot prove the trigger reaches the line, append `(unverified)` and cap the severity at `major`. An unverified finding never blocks a merge.

## Examples

`src/billing/invoice.ts:L48: bug critical: total sums line prices before applying quantity. Trigger: any line with quantity > 1. Multiply before summing.`

`src/sync/worker.go:L112: race major: two workers can claim the same job between SELECT and UPDATE. Trigger: two workers polling within the same tick. Claim with UPDATE ... RETURNING in one statement.`

`src/upload.py:L30: leak major: file handle not closed when validate() raises. Trigger: upload with an invalid header. Use a with block.`

`src/dates.ts:L19: edge minor: week number off by one for 31 Dec in ISO week-1 years. Trigger: 2024-12-31. Use the ISO week from Intl or date-fns.`

`src/client.rb:L77: swallow major: rescue => e returns nil, caller treats nil as "no records". Trigger: API timeout. Re-raise or return an error result.`

## End line

```
correctness: <critical> critical, <major> major, <minor> minor. <unverified> unverified.
```

If nothing found: `correctness: no bugs found. Ship.`

## Boundaries

Scope: behaviour that is wrong for some input or state. Not spec conformance (`/mattstack:review-spec`), not complexity (`/mattstack:review-lazy`, `/mattstack:review-abstraction`), not security (`/mattstack:review-security`) — a bug an attacker can exploit goes to review-security only. Style and naming are out of scope. Does not apply fixes; only lists them.
