# mattstack

Opinionated dev workflow for Claude Code, shipped as a plugin.

Flow: **grill** a plan → cut a **spec** → drive **TDD** AFK → **review** the diff against spec, laziness, and abstraction cost.

Self-contained — no other plugins required.

## Install

```sh
ln -s ~/dev-env/agents/mattstack ~/.claude/skills/mattstack
```

**Restart Claude Code.** `/reload-plugins` alone will not pick up a newly added plugin directory — it only reloads plugins already known to the session. Once loaded, subsequent edits to any `SKILL.md` are picked up by `/reload-plugins`.

Skills appear under `/mattstack:*`.

## Skills

| Skill | Purpose |
|---|---|
| `/mattstack:grill` | Socratic interview that surfaces every open decision behind a plan. |
| `/mattstack:spec` | Turns a grill session (or freeform notes) into a spec doc. |
| `/mattstack:tdd-loop` | Splits a spec into ordered slices and drives red-green-refactor AFK. |
| `/mattstack:review` | Fans out to the three specialist reviewers in parallel and aggregates. |
| `/mattstack:review-spec` | Diff vs spec doc — does the code deliver what was specified? |
| `/mattstack:review-lazy` | YAGNI / delete-first review, one line per finding. |
| `/mattstack:review-abstraction` | Does each new abstraction earn its keep? |

## End-to-end example

Adding a new feature — "session timeout after 15 minutes of inactivity":

```
1. /mattstack:grill
   → Answer numbered rounds until frontier empty.
   → Confirm shared understanding.
   → Grill emits the decisions digest.

2. /mattstack:spec
   → Consumes the digest.
   → Writes ./specs/session-timeout.md
   → Prints: "Spec written. Behaviours: 4. Open questions: 0."

3. /mattstack:tdd-loop ./specs/session-timeout.md
   → Splits into ordered slices, prints the plan.
   → Wait for "go".
   → Drives red-green-refactor per slice, AFK.
   → Halts only on real blockers.
   → At end, runs /mattstack:review and prints the aggregated report.

4. Eyeball the diff. Merge or push back to grill.
```

Any skill is also usable standalone:

```
/mattstack:review           # review current branch against merge-base
/mattstack:review-lazy      # only the delete-first pass
/mattstack:grill            # stress-test any plan without proceeding to spec
```

## Attributions

- `skills/grill/` adapted from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT, © 2026 Matt Pocock).
- `skills/review-lazy/` adapted from [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) (MIT, © 2026 DietrichGebert).
- Skill-authoring discipline informed by [obra/superpowers](https://github.com/obra/superpowers) (MIT, © 2025 Jesse Vincent) — methodology only, no content bundled.

See [NOTICE](./NOTICE) for full attributions.

## License

MIT. See [LICENSE](./LICENSE).
