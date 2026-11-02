---
name: board
description: Beta. Drain a local ticket board in small batches. Pickup grills each ticket and gets its slice plan approved; then each ticket is built, verified and reviewed unattended with mattstack skills and handed off for peer review. Never calls a tracker or forge — wherever super-board would touch GitHub, it asks the user what to do. State lives in `~/.claude/specs/<repo>/`, never in the repo. Verbs: add, status, run. Use when the user says "board", "add a ticket", "what's on the board", "drain the board", "pick up the next tickets", or pastes a ticket link to queue.
license: MIT
---

# Board

A board of tickets, drained a batch at a time. Each stage is an existing mattstack skill; this skill only moves tickets between columns, keeps state, and asks the user at every point that touches an outside system.

## Where state lives

Directory: `~/.claude/specs/<repo>/`, where `<repo>` is the basename of `git rev-parse --show-toplevel`. Same directory the mattstack skills write to.

- `tickets/<KEY>.md` — one file per ticket (shape below).
- `board.md` — handoff answers the user asked to remember (see Ask points).
- Per ticket, named `<item>` = `<KEY>-<slug>` (e.g. `PROJ-123-session-timeout`, `L-4-csv-export`): `<item>.digest.md`, `<item>.md` (spec), `<item>.slices.md` (approved slice plan), `<item>.verify.md`, `<item>.handoff.md`.

Never write state, notes or logs inside the repo. Never touch the repo's `.gitignore`.

## Ticket file

```
---
key: <KEY>
title: <short title>
status: backlog | ready | building | qa | review | done | blocked
source: <URL, or "free text">
item: <KEY>-<slug, set at pickup>
branch: <set at build>
base: <set at build>
bounces: 0
halt: <one-line reason, empty unless blocked>
updated: <YYYY-MM-DD>
---

## What to build
<ticket body as given>

## Acceptance criteria
- <one per line, if the ticket has them>

## Log
- <YYYY-MM-DD> <status>: <one-line outcome>
```

Rewrite the frontmatter and append one log line on every status change.

`review` means handed off for peer review. `done` means a human merged it.

## Ask points

The board connects to nothing. At each point below, ask the user and wait — unless `board.md` holds a remembered answer for that point, in which case act on it and say so in one line.

After the user answers, offer once: "Remember this for <repo>?" Yes → append under that point's heading in `board.md`. A remembered answer may be an instruction ("I'll do it myself, just remind me") or commands to run (`glab mr create --draft ...`). Run remembered commands only as written, and show each before running it.

| Point | Ask |
|---|---|
| **fetch** | A ticket was added by link. "Paste the ticket's description and acceptance criteria, or say if I can fetch it." Never guess the content from the URL. |
| **claim** | At pickup, per ticket. "Claim <KEY> in your tracker (assign, move to In Progress)?" — the user does it, or gives commands. |
| **deliver** | At the end of a batch, per ticket that reached `review`. "How should <branch> get to peer review?" Default suggestion: push the branch and open a draft PR/MR with `<item>.handoff.md` as the body. |
| **move** | After deliver. "Move <KEY> to your review column?" |
| **merged** | At the start of `run` or `status`, for every ticket in `review`. "Has <KEY> been merged?" Yes → `done`. |

Nothing here may push, open a PR/MR, or change a tracker without the user's answer or a remembered answer for that exact point.

## Verbs

No verb → print `status`, then ask whether to `add` or `run`.

### add `<link | text>`

1. A link → note it as `source`, then **fetch**. The key is the tracker's key if the link or text shows one (`PROJ-123`, `#42`); otherwise ask, or offer the next local key.
2. Free text → `source: free text`, key `L-<n>`, where n is one more than the highest local key on the board.
3. Write `tickets/<KEY>.md` with `status: ready`. If the text is too thin to tell what to build, say so; it still goes on the board, because grill fills it in at pickup.
4. Print the key and the board's ready count.

Several tickets can be added in one message.

### status

Ask **merged** first. Then print the board grouped by status, oldest first within a group: key, title, and the halt reason for blocked tickets. Read-only apart from the merged answers.

### run `[N]`

N is the batch size, default 2. A dirty working tree → stop and ask the user to commit or stash.

1. **Merged check.** Ask **merged**.
2. **Pick.** The N oldest `ready` tickets. None → say so and offer `add`. Print the batch and wait for "go" or a different pick.
3. **Pickup**, per ticket in the batch, in order. This part is a conversation with the user by design.
   1. **claim**.
   2. `/mattstack:grill` with the ticket body and acceptance criteria. Propose the slug at the end. Write the digest to `<item>.digest.md`; set `item:`.
   3. `/mattstack:spec` with the digest and slug `<item>`. Open questions > 0 → resolve them now, while the user is here. The spec must land at `<item>.md`; overwrite rather than write a `-v2`.
   4. `/mattstack:tdd-loop` with `<item>.md`, **split and approval gate only**. Write the approved plan to `<item>.slices.md`. Do not start the slices yet.
   5. Status `building`. Grill abandoned → leave it `ready` and move on.
4. **Build**, per ticket, one at a time. Unattended from here: no questions until the batch report.
   1. Check out the batch's starting branch; record it as `base`. Create and switch to local branch `<item>`; record it as `branch`.
   2. **build** — `/mattstack:tdd-loop` with `<item>.md`, the plan in `<item>.slices.md`, and this note: "Slice plan approved by the user on <date> at pickup; go." `HALT at S<n>` → `blocked` with that line; next ticket.
   3. Status `qa`. **qa** — `/mattstack:verify` with `<item>.md`. `verify: halt.` → bounce.
   4. **review** — `/mattstack:review` with the diff `<base>...HEAD` and spec `<item>.md`. `verdict: revise` or `verdict: block` → bounce.
   5. `verdict: ship` → write `<item>.handoff.md` (shape below), status `review`.
   6. Switch back to `base` before the next ticket.
5. **Report and deliver.** Print the batch report (below). Then **deliver** and **move** for each ticket that reached `review`. Stop. The next batch is a fresh `run`.

#### Bounce

The super-board loop: a failing lane sends the ticket back to build with the evidence.

- `bounces` < 2 → increment it, log the failing lane and its summary line, and run `/mattstack:tdd-loop` on the failing behaviours or findings only, with the verify report or review findings as the brief. Then resume from **qa**.
- `bounces` = 2 → `blocked` with the last failing line; next ticket.

#### Resume

`run` with no `ready` tickets but some in `building` or `qa` (a session ended mid-build) → offer to carry on with those. A ticket's resume point is its status; tdd-loop's own red-step rule proves and skips slices already done.

## Handoff file

`<item>.handoff.md`, written to be pasted as a PR/MR body:

```
## <KEY>: <title>

<two or three sentences: what changed and why, from the spec>

### Behaviours
- <numbered spec behaviour> — <verify evidence, one line>

### Review
verdict: ship. <any minor findings left, one line each, or "none">

### Not verified
<behaviours verify could not check, or "none">

Ticket: <source>
```

No AI attribution lines.

## Batch report

```
Batch done: <n> tickets.
- <KEY> review   <branch>  handoff: ~/.claude/specs/<repo>/<item>.handoff.md
- <KEY> blocked  <halt reason>
Board: <ready> ready · <review> in review · <blocked> blocked
```

## Boundaries

- Never merge.
- Never push, open a PR/MR, or touch a tracker except through an ask point.
- Never edit the repo outside what a stage skill does.
- A stage skill's own rules win over this one where they overlap (tdd-loop's commit and trailer rules, spec's shape), except the slice-plan approval, which pickup collects up front.
