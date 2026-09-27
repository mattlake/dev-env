---
name: review-lazy
description: Code review focused exclusively on over-engineering. Finds what to delete — reinvented standard library, unneeded dependencies, speculative abstractions, dead flexibility. One line per finding: location, what to cut, what replaces it. Use when the user says "review for over-engineering", "what can we delete", "is this over-engineered", "lazy review", or when `/mattstack:review` fans out. Complements correctness-focused review; this one only hunts complexity.
license: MIT
---

<!--
Adapted from DietrichGebert/ponytail — the "ponytail-review" skill and the
"ponytail" persona.
Source: https://github.com/DietrichGebert/ponytail
Copyright (c) 2026 DietrichGebert. Licensed under MIT.
See NOTICE at repo root.
-->

# Review — laziness

Review diffs for unnecessary complexity. One line per finding: location, what to cut, what replaces it. The diff's best outcome is getting shorter.

## The ladder

Every added line is judged against the ladder. Stop at the first rung that flags:

1. **Does it need to exist at all?** Speculative feature, unused flag, "for later" scaffolding. Flag with `delete:`.
2. **Does the codebase already do it?** Reinvented helper, duplicated pattern. Flag with `delete:` and name the existing thing.
3. **Does stdlib do it?** Flag with `stdlib:` and name the function.
4. **Does the platform / framework do it natively?** Flag with `native:` and name the feature.
5. **Is it a comment?** Every comment the diff adds is a finding. Names, test names and commit messages carry the intent instead. Flag with `delete:`.
6. **Is there a one-implementation abstraction?** Interface with one impl, factory for one product, config nobody sets, layer with one caller. Flag with `yagni:`.
7. **Can it be shorter?** Same logic, fewer lines. Flag with `shrink:` and show the shorter form.

## Format

`<file>:L<line>: <tag> <what>. <replacement>.`

Tags (same as ladder rungs):

- `delete:` dead code, unused flexibility, speculative feature, added comment. Replacement: nothing, or a better name when the comment was explaining a bad one.
- `stdlib:` hand-rolled thing the standard library ships. Name the function.
- `native:` dependency or code doing what the platform already does. Name the feature.
- `yagni:` abstraction with one implementation, config nobody sets, layer with one caller.
- `shrink:` same logic, fewer lines. Show the shorter form.

## Examples

`L12-38: stdlib: 27-line email validator class. "@" in email, 1 line, real validation is the confirmation mail.`

`L4: native: moment.js imported for one format call. Intl.DateTimeFormat, 0 deps.`

`repo.py:L88: yagni: AbstractRepository with one implementation. Inline it until a second one exists.`

`L52-71: delete: retry wrapper around an idempotent local call. Nothing replaces it.`

`L17-19: delete: 3-line doc comment restating what `firstDifference` returns. Nothing, the name says it.`

`L30-44: shrink: manual loop builds dict. dict(zip(keys, values)), 1 line.`

## Inputs

Default: `git diff <merge-base>...HEAD`. User can supply a range or paste a diff. If not in a git repo, ask.

## Scoring

End with the only metric that matters:

```
lazy: net -<N> lines possible.
```

If nothing to cut: `lazy: lean already. Ship.` and stop.

## Boundaries

Scope: over-engineering and complexity only. Correctness bugs, security holes, and performance are explicitly out of scope — route those to a normal review pass or the appropriate specialist skill. A single smoke test or `assert`-based self-check is the minimum, not bloat — never flag it for deletion. Does not apply fixes; only lists them.

Before resting a finding on a claim about performance, allocation, or how a tool or library behaves, check it: run a benchmark, `-gcflags=-m`, a quick script, or read the source. If you can't check it, label the finding `(unverified)`. A reason that turns out false is worse than no reason.
