---
name: run
description: Drive one item through the whole mattstack pipeline — grill, spec, tdd-loop, review — advancing on its own and stopping only where a stage halts. State lives in `~/.claude/specs/<repo>/`, never in the repo, so a run can be resumed in any later session. With no argument, lists items in flight for this repo. Use when the user says "run this", "start a run", "factory this", "what's in flight", "resume", or "carry on with <slug>".
license: MIT
---

# Run

One item, start to finish. Each stage is an existing mattstack skill; this skill only sequences them and keeps the state.

## Where state lives

Directory: `~/.claude/specs/<repo>/`, where `<repo>` is the basename of `git rev-parse --show-toplevel`. Same directory `/mattstack:spec` writes to.

Per item `<slug>`:

- `<slug>.state.md` — stage and status (shape below).
- `<slug>.digest.md` — the decisions digest from grill.
- `<slug>.md` — the spec.

Never write state, notes or logs inside the repo. Never touch the repo's `.gitignore`.

## State file

```
---
slug: <slug>
branch: <branch>
base: <branch the run started from>
stage: grill | spec | tdd-loop | review | done
status: running | halted | done
halt: <one-line reason, empty unless halted>
updated: <YYYY-MM-DD>
---

## Log
- <YYYY-MM-DD> <stage>: <one-line outcome>
```

Rewrite the frontmatter and append one log line every time a stage finishes or halts.

## Invocation

- **No argument.** List every `*.state.md` in the directory whose status is not `done`: slug, stage, status, halt reason. One item → ask "Continue <slug>?". None → say so and ask what to build. Otherwise ask which.
- **An existing slug.** Resume it.
- **Anything else.** A description of new work. Start a new item.

## Start a new item

1. Propose a slug (short, kebab-case) and confirm it. If `<slug>.state.md` exists, offer to resume it instead.
2. Refuse to start on a dirty working tree; ask the user to commit or stash.
3. Record the current branch as `base`. Create and switch to a local branch named `<slug>`. Never push it.
4. Write the state file with `stage: grill`, `status: running`.
5. Enter the stage loop.

## Resume

1. Read the state file. Check out its `branch` if not already on it; if the working tree is dirty with changes from another branch, halt and ask.
2. If `status: halted`, print the halt reason and ask whether it is resolved. Resolved → set `status: running`. Not → stop.
3. Enter the stage loop at `stage`.

## Stage loop

Run the current stage, record the outcome, move on without asking. Stop only on a halt or at `done`.

### grill

Invoke `/mattstack:grill` with the item description. This stage is a conversation with the user by design.

- Digest emitted → write it to `<slug>.digest.md`, advance to `spec`.
- User abandons the grill → halt: `grill not finished`.

On resume, if `<slug>.digest.md` already exists, skip straight to `spec`.

### spec

Invoke `/mattstack:spec` with `<slug>.digest.md` and the slug. The spec must land at `<slug>.md`; if spec offers `<slug>-v2.md`, overwrite instead — this run owns that path.

- Open questions: 0 → advance to `tdd-loop`.
- Open questions > 0 → halt: `spec has <M> open questions`. On resume, re-read `<slug>.md`; advance once the user has answered them or accepted them as assumptions.

### tdd-loop

Invoke `/mattstack:tdd-loop` with `<slug>.md`. Its approval gate stays: the user still replies "go" to the slice plan.

- `HALT at S<n>` → halt with tdd-loop's reason line.
- Loop done → record the final verdict from its closing review, then treat it as the `review` stage's result (below) without re-running review.

On resume, run tdd-loop again from the split. Slices already implemented are proved and marked by tdd-loop's own red-step rule.

### review

Invoke `/mattstack:review` with the diff `<base>...HEAD` and spec `<slug>.md`.

- `verdict: ship` → `stage: done`, `status: done`.
- `verdict: revise` or `verdict: block` → halt with the verdict line. On resume, run review again.

## Done

Print:

```
Run done: <slug>
Branch: <branch> (local, not pushed)
Spec: ~/.claude/specs/<repo>/<slug>.md
Verdict: ship.
Next: eyeball the diff, then merge or push yourself.
```

## Boundaries

- Never push, open a PR, or merge. Delivery is the user's call.
- Never edit the repo outside what a stage skill does.
- One item per invocation. Running several at once is out of scope.
- A stage skill's own rules win over this one where they overlap (tdd-loop's commit and trailer rules, spec's shape).
