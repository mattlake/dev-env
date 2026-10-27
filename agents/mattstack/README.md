# mattstack

Opinionated dev workflow for Claude Code, shipped as a plugin.

Flow: **grill** a plan → cut a **spec** → drive **TDD** AFK → **verify** it runs → **review** the diff for spec conformance, bugs, security, performance, laziness, and abstraction cost. `/mattstack:run` drives the whole chain and keeps resumable state.

Self-contained — no other plugins required.

## Install

```sh
ln -s ~/dev-env/agents/mattstack ~/.claude/skills/mattstack   # or run install/wsl.sh / install/macos.sh
```

**Restart Claude Code.** `/reload-plugins` alone will not pick up a newly added plugin directory — it only reloads plugins already known to the session. Once loaded, subsequent edits to any `SKILL.md` are picked up by `/reload-plugins`.

Skills appear under `/mattstack:*`.

## Skills

| Skill | Purpose |
|---|---|
| `/mattstack:run` | Drives one item through grill → spec → tdd-loop → verify → review; state in `~/.claude/specs/<repo>/`, resumable. |
| `/mattstack:grill` | Socratic interview that surfaces every open decision behind a plan. |
| `/mattstack:spec` | Turns a grill session (or freeform notes) into a spec doc. |
| `/mattstack:tdd-loop` | Splits a spec into ordered slices and drives red-green-refactor AFK. |
| `/mattstack:verify` | Runs build/typecheck/lint, then exercises each spec behaviour in the running app. Halts on any failure. |
| `/mattstack:review` | Fans out to the six specialist reviewers in parallel and aggregates. Takes the current branch, a range, a branch name, or a GitHub PR / GitLab MR link. |
| `/mattstack:review-spec` | Diff vs spec doc — does the code deliver what was specified? |
| `/mattstack:review-correctness` | Bug hunt — every finding names the input or state that triggers it. |
| `/mattstack:review-security` | Traces untrusted input from source to sink — injection, authz, secrets, exposure, deps. |
| `/mattstack:review-performance` | Costs that grow with data — N+1, quadratic, unbounded, blocking, missing index. Names the scale. |
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
   → Writes ~/.claude/specs/<repo>/session-timeout.md
   → Prints: "Spec written. Behaviours: 4. Open questions: 0."

3. /mattstack:tdd-loop ~/.claude/specs/<repo>/session-timeout.md
   → Splits into ordered slices, prints the plan.
   → Wait for "go".
   → Drives red-green-refactor per slice, AFK.
   → Halts only on real blockers.
   → At end, runs /mattstack:review and prints the aggregated report.

4. Eyeball the diff. Merge or push back to grill.
```

Or let `/mattstack:run` sequence the steps above:

```
/mattstack:run session timeout after 15 minutes idle   # new item, local branch session-timeout
/mattstack:run                                         # list items in flight, pick one
/mattstack:run session-timeout                         # resume after a halt
```

Any skill is also usable standalone:

```
/mattstack:review           # review current branch against merge-base
/mattstack:review https://gitlab.example.com/team/app/-/merge_requests/42   # any PR or MR, local report only
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
