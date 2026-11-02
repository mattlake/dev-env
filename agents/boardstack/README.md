# boardstack (beta)

A vendor-neutral take on [super-board](https://github.com/EricTechPro/super-board): drop tickets on a board, drain them a batch at a time, get branches back that are ready for peer review.

Unlike super-board it connects to nothing. The board is local files. Wherever super-board would call GitHub (fetch a ticket, claim it, open a PR, move a card), boardstack asks you what to do, and can remember your answer per repo.

Requires the [mattstack](../mattstack) plugin: every stage is a mattstack skill.

## Install

```sh
ln -s ~/dev-env/agents/boardstack ~/.claude/skills/boardstack   # or run install/wsl.sh / install/macos.sh
```

Restart Claude Code. Skills appear under `/boardstack:*`.

## Flow

```
/boardstack:board add <ticket link or free text>   # queue tickets
/boardstack:board run                              # batch of 2: grill each, then build → qa → review unattended
/boardstack:board status                           # what's where
```

Per ticket: **pickup** (claim, grill, spec, approve the slice plan — you're here) → **build** (`tdd-loop`) → **qa** (`verify`) → **review** (`review`) → handoff note for the PR/MR body. A failing qa or review bounces the ticket back to build, twice at most, then it's blocked.

Columns: `backlog · ready · building · qa · review · done · blocked`. `review` means handed off for peer review; `done` means a human merged it.

State lives in `~/.claude/specs/<repo>/`: `tickets/`, `board.md` (remembered answers), and per-ticket digest, spec, slice plan, verify report and handoff. Nothing is written into the repo.

## Not yet

Tracker and forge integrations, parallel builds, super-board's own build/QA/review lanes, guard hooks.

## Attributions

Board, lanes, bounce loop and merge-gate idea follow [EricTechPro/super-board](https://github.com/EricTechPro/super-board) (MIT, © Eric Tech) — design only, no content bundled. Ticket body shape follows mattpocock/skills `to-tickets`.

## License

MIT. See [LICENSE](./LICENSE).
