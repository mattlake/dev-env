---
name: verify
description: Prove a finished feature works by running it, not by reading it. Runs the repo's own build, typecheck and lint, then starts the app and exercises every numbered spec behaviour the way a user would, recording evidence per behaviour. Halts on any failure. Never edits the repo. Use when the user says "verify this", "does it actually work", "run it against the spec", or when `/mattstack:run` reaches the verify stage.
license: MIT
---

# Verify

Green tests prove the tests pass. Verify proves the feature does what the spec says when someone actually uses it.

## Inputs

1. **Spec path**: supplied by the user or by `/mattstack:run`. Otherwise pick the spec in `~/.claude/specs/<repo>/` the same way `/mattstack:review` does. No spec → ask the user for the behaviours to check, or stop.
2. **Slug**: the spec's basename without `.md`.

## Where output goes

Report: `~/.claude/specs/<repo>/<slug>.verify.md`. Scratch scripts, logs and screenshots: `~/.claude/specs/<repo>/<slug>.verify/`. Overwrite both on each run.

Nothing goes in the repo. Record `git status --porcelain` before starting; it must be identical at the end.

## Phase 1 — Project checks

Run every build, typecheck and lint command the repo already defines. Do not install tools or add config to get one running.

- `package.json` → the `build`, `typecheck`, `lint` scripts that exist; `tsc --noEmit` if there is a `tsconfig.json` and no typecheck script
- `go.mod` → `go build ./...`, `go vet ./...`
- `Cargo.toml` → `cargo build`, `cargo clippy` if installed
- `.csproj` / `*.sln` → `dotnet build`
- `pyproject.toml` → whichever of ruff, mypy, pyright it configures
- A `Makefile` or `justfile` target named `build`, `check` or `lint` → prefer it over the above

Any non-zero exit is a failure. Record the command and the decisive error lines.

## Phase 2 — Behaviour checks

For each numbered behaviour in the spec, in order:

1. **Pick the surface** a user would touch: CLI invocation, HTTP request, browser UI, or the public API for a library. Use Claude Code's built-in `/run` skill to launch the app when it is available; otherwise start it the way the README or `package.json` scripts say.
2. **Exercise it.** Drive the exact inputs the behaviour names. For a library, write a throwaway script in the scratch directory that imports the package and calls it.
3. **Observe** the effect the behaviour names: output, status code, response body, DOM state, file written, row stored.
4. **Record** one verdict with evidence: the command or steps, and the shortest excerpt that proves the result.

Verdicts:

- `verified:` the observed effect matches the behaviour.
- `failed:` the effect is missing or wrong, or the app would not start.
- `unverifiable:` checking needs something verify must not or cannot use: production or shared environments, real credentials, paid third-party calls, hardware. Name the blocker. "Hard to set up" is not a blocker; set it up.

Only local resources. Local dev servers, local databases, test fixtures and sandbox modes are fine. If the only environment available is shared or real, the behaviour is `unverifiable`.

Stop every process you started before moving on.

## Report

Write to `<slug>.verify.md` and print:

```
## Verify — <slug>

### Project checks
<command>: pass
<command>: fail — <decisive error line>

### Behaviours
B1 verified: <one line>. Evidence: <command → excerpt>
B2 failed: <expected> but <observed>. Evidence: <command → excerpt>
B3 unverifiable: <blocker>.

verify: <v> verified, <f> failed, <u> unverifiable. checks: <pass|fail>.
```

## Halt

Any failed project check, any `failed` behaviour, or a `git status` that differs from the start → print `verify: halt.` after the summary line, and stop. Do not fix anything; the fix goes back through `/mattstack:tdd-loop`.

Otherwise print `verify: pass.` and list the `unverifiable` behaviours under it so the user knows what to check by hand.

## Boundaries

- Never edit, create or delete files in the repo. Never commit.
- Never call production or shared systems, send real email or messages, or spend money.
- Does not judge code quality or test coverage; that is `/mattstack:review`'s job.
