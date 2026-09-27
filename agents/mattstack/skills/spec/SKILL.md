---
name: spec
description: Cut a spec doc from a grill session's decisions digest OR from freeform notes. The spec is the single artifact `/mattstack:tdd-loop` splits into slices and `/mattstack:review-spec` checks the diff against. Use after `/mattstack:grill`, or when the user says "spec this", "write the spec", "turn this into a spec".
license: MIT
---

# Spec

Turn a plan into a spec doc that downstream skills can consume.

## Input

One of:

1. **Decisions digest** from `/mattstack:grill` (has `## Decisions`, `## Open assumptions`, `## Out of scope`).
2. **Freeform notes** the user pastes or dictates.

If neither is obvious, ask which. Do not invent a decisions digest.

## Where the spec lives

Write to `./specs/<slug>.md` in the current repo (create `specs/` if missing). Slug from the feature name — kebab-case, short. Print the path when done. If a spec at that path exists, ask before overwriting; offer to write `<slug>-v2.md` instead.

## Spec shape

```
# <Feature name>

## Goal
<One paragraph. What changes for the user or the system when this ships. No implementation.>

## Behaviours
Each numbered. Each testable. Each one behaviour, not a bundle.

1. <Given/when/then, or a plain declarative sentence that names the observable effect.>
2. ...

## Non-goals
- <Explicitly out of scope — from grill's "Out of scope" if present, plus anything obvious from the plan.>

## Constraints
- <Tech, perf, compat, security, deadline. Anything that would fail the review if violated.>

## Open questions
- <Anything the grill left as "open assumption", or that surfaced while writing this. These must be answered before `/mattstack:tdd-loop` runs.>

## Decisions log
<Copy the digest from grill verbatim if present. Otherwise, extract the decisions implicit in the freeform input and list them in the same D1/D2 format. This is the receipt: it shows why the spec is what it is.>
```

## Rules

- **Behaviours are testable.** If you cannot picture a test that would fail without the code, the behaviour is too vague. Rewrite or split.
- **One behaviour per numbered item.** No "and". No comma-separated lists of effects. `/mattstack:tdd-loop` splits on these — a fat behaviour becomes a fat slice.
- **Ladder pressure.** Before writing each behaviour, ask: does this exist in the codebase already? Is it stdlib? Is it a native platform feature? If yes, the behaviour is "wire up X", not "build X".
- **No implementation prose.** The spec says what, not how. Filenames, class names, and algorithms belong in the code, not here. Constraints are the exception (`must use existing AuthMiddleware`).
- **Open questions block downstream skills.** If any remain, print a warning and tell the user to answer them or accept them explicitly as assumptions before running `/mattstack:tdd-loop`.

## Output

After writing the file, print:

```
Spec written: ./specs/<slug>.md
Behaviours: <N>
Open questions: <M>
Next: /mattstack:tdd-loop ./specs/<slug>.md
```

If M > 0, print the open questions inline and warn that tdd-loop should not run until they are resolved.
