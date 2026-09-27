---
name: tdd-loop
description: Split a spec (or freeform notes) into ordered slices, get approval, then drive red-green-refactor AFK — one behaviour per slice, dependency ordered, shared-state changes batched to avoid version-bump churn. Halts only on real blockers (test won't go green, critical review finding, build fails, spec gap). Autodetects test framework. Use when the user says "tdd this", "drive this spec", "afk loop", or after `/mattstack:spec` produces a spec.
license: MIT
---

# TDD loop

Split, approve, drive AFK. Stop only when stopping is the right move.

## Inputs

One of:

1. **Spec doc** — path passed by the user or emitted by `/mattstack:spec`. Preferred.
2. **Freeform notes** — the user pastes goals. Behaviours are less crisp; splitting may need more inference.

If neither is obvious, ask which.

## Phase 1 — Split

Read the input. Enumerate every testable behaviour. For each behaviour, propose ONE slice.

A slice = one failing test → green → refactor cycle. One behaviour per slice. No "and".

### Ordering rule

Dependency-first. If slice B needs the code from slice A to exist, A comes first. Ties broken by risk: unknowns earlier so the loop learns before it commits.

### Shared-state batching

Never split changes to the following across multiple slices — batch them into one slice each:

- Database migrations (one migration slice per feature; never two migrations for one feature)
- Package manifest updates (`package.json`, `requirements.txt`, `pyproject.toml`, `Gemfile`, `go.mod`, `.csproj`, etc.) — one dep-bump slice, all adds together
- Framework upgrades (never mixed with feature slices)
- Config schema changes

Rationale: version-bumping the same file twice in one feature means two review passes on churn that could have been one.

### Ponytail voice at split time

Before locking each slice, climb the ladder:

1. Does this slice need to exist at all? Speculative → drop.
2. Does the codebase already do it? Reuse; slice becomes "wire up existing X".
3. Stdlib / native platform / already-installed dep? Prefer over custom.
4. Can the slice be smaller? Split further if a smaller failing test still moves the feature forward.

If a slice ships more than the smallest thing that moves the behaviour, shrink it or note the ladder-rung skipped.

### Autodetect the test framework

Detect from the repo:

- `package.json` → jest / vitest / mocha (check `devDependencies` + `scripts.test`)
- `pyproject.toml` / `setup.py` / `pytest.ini` → pytest
- `Gemfile` → rspec / minitest
- `go.mod` → `go test`
- `.csproj` / `*.sln` → xunit / nunit / mstest
- `Cargo.toml` → `cargo test`
- Angular `angular.json` → karma / jasmine
- React (`react-scripts` / vite) → jest / vitest / rtl

On ambiguity (two candidates, no scripts to disambiguate), ask.

### Slice plan output

```
## Slice plan for <feature name>

Framework detected: <name> (`<test command>`)

### S1 — <slice title>
Behaviour: <spec ref or paraphrase>
Failing test: <one-line description of what test proves the behaviour>
Files likely touched: <list>
Ladder rung: <which rung the implementation stops at>
Blocks: <slice IDs that depend on this one, if any>

### S2 — ...
```

End with:

```
Total slices: <N>. Shared-state slices: <M>. Estimated wall-clock: <rough range>.

Approve to run AFK: reply "go" or edit the plan first.
```

## Phase 2 — Approval gate

Do not proceed without explicit user approval. Edits to the plan re-print it. "Go" starts Phase 3.

## Phase 3 — Drive AFK

For each slice in order:

1. **Red.** Write the failing test. Run the framework. Confirm it fails for the right reason (not a syntax error).
2. **Green.** Write the minimum code to make it pass. Run full test file, then full suite. Both must pass.
3. **Refactor.** Improve structure without changing behaviour. Re-run suite. Must still pass.
4. **Log.** Append to `./specs/<slug>-log.md` (or a scratch log if freeform input): slice ID, files changed, test added, notes.

### Halt criteria (surface to user, stop)

Halt and surface only when:

- Red test fails to go green after 3 attempts on the same slice.
- Any specialist review skill flags `critical` when consulted mid-slice (see below).
- Build / install / migration command exits non-zero and retrying with obvious fix fails.
- Spec gap discovered — required behaviour is underspecified or the spec contradicts itself. Do not guess.
- Any command asks for interactive input the loop cannot answer.

Anything else — flaky test, transient network, formatting nit — retry once, then proceed.

### Mid-slice review consultation

Only for slices flagged "risky" during split (new abstraction introduced, shared-state change, security-sensitive path). Otherwise defer review to the end.

For risky slices, after green:

- Invoke `/mattstack:review-lazy` on the slice diff.
- Invoke `/mattstack:review-abstraction` on the slice diff.

If either returns `critical` or a `net -N` where N exceeds the slice's added lines, halt.

### End-of-run

When all slices complete:

1. Run `/mattstack:review` on the full branch diff. Print the aggregated report.
2. Print a summary:

```
Loop done. <N>/<N> slices green. <halts> halts along the way (see log).
Final verdict: <from /mattstack:review>.
Handoff: your turn to eyeball the diff and merge.
```

## Boundaries

- Never force-push, never `git reset --hard` without explicit request.
- Never delete files not in the slice plan.
- Never skip a failing test to move on — halt and surface.
- Never disable a hook or bypass a pre-commit check to make green happen.
- Commits per slice: one per green, using conventional-commit format `feat(<scope>): <slice title>` (or `test:` for pure test slices). No amend.

## Output on halt

```
HALT at S<n>: <reason>.
Slice title: <...>
What I tried: <two or three lines>
What I need from you: <one line>
Log so far: ./specs/<slug>-log.md
```

Do not resume automatically after halt. Wait for the user.
