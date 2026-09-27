---
name: grill
description: Socratic interview that surfaces every open decision behind a plan, feature, or design. One numbered question at a time with a recommended answer, until the design tree is fully explored. Ends with a structured decisions digest ready for `/mattstack:spec` to consume. Use when the user says "grill me", "stress-test this plan", "grill this idea", "pre-mortem", "what am I missing", or before starting any non-trivial build.
license: MIT
---

<!--
Adapted from mattpocock/skills "grilling" skill.
Source: https://github.com/mattpocock/skills/tree/main/skills/productivity/grilling
Copyright (c) 2026 Matt Pocock. Licensed under MIT.
See NOTICE at repo root.
-->

# Grill

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Work out the whole frontier, but ask **one question per message**. Pick the most foundational one first, the one whose answer is most likely to reshape or remove others. Number it, give your recommended answer, then stop and wait.

Ask in plain text in your reply. Do not use the built-in question picker (`AskUserQuestion` or similar). The user answers in their own words, and may push back, ask a follow-up, or change the question.

## Question format

```
Q<n> - <question title>

<question body, might be multiple paragraphs, including multiple choices>

Recommend: <your recommended answer>
```

Keep numbering across the whole session, so Q4 is the fourth question asked. Each answer reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them, and may make queued questions moot. Recompute the frontier after every answer before choosing the next question. Drop any question an answer has made moot, and say so in one line.

## Fact-finding vs decisions

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, package versions, existing code), dispatch a sub-agent or run the lookup yourself; don't ask the user for anything you could find out. Don't block on it: a running exploration is an unsettled prerequisite, so only questions downstream of it wait; ask something else from the frontier in the meantime.

Before building the frontier, look for decisions that are already made. Search earlier sessions for this project (`~/.claude/projects/<project>/*.jsonl`), task files, specs, notes and the code itself for the topic. Task files often lag behind decisions made in conversation. Record anything already settled as settled, with where you found it, and don't ask it again. If you disagree with a settled decision, say so once and let the user decide whether to reopen it.

Never put an unchecked claim about a tool, library, or performance into a recommendation or a rationale. Measure it or read the source first. If that can't be done now, mark the claim `(unverified)` in the question and in the digest.

The _decisions_ are the user's: put each to them and wait.

## Laziness pressure at plan time

Every decision under review is a chance to shrink scope. When you form your recommendation, first climb the ladder:

1. Does this decision need to exist at all? Speculative → drop it, say so in one line.
2. Does the existing codebase already solve it? Reuse over new.
3. Does stdlib / the framework / the platform cover it? Prefer over custom.
4. Can the answer be "not yet"? Defer until a real requirement forces the hand.

If the recommended answer is more than the smallest thing that works, name the simpler alternative in the same recommendation and let the user pick.

## Termination

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms shared understanding.

When the user confirms, emit the **decisions digest** below in one block. This is the handoff to `/mattstack:spec`.

## Decisions digest (final output)

```
## Decisions

### D1 — <decision title>
Question: <the question that was on the table>
Settled: <the answer the user chose>
Rationale: <one line — why this over the alternatives>

### D2 — <decision title>
Question: <...>
Settled: <...>
Rationale: <...>

## Open assumptions
- <anything the user did not confirm but that the plan implicitly depends on>

## Out of scope
- <anything explicitly ruled out during the session>
```

Every decision from every question belongs in the digest, in the order they settled. If a decision was answered "defer" or "not yet", record it — future spec revisions may return to it.
