---
name: grill
description: Socratic interview that surfaces every open decision behind a plan, feature, or design. Numbered questions with recommended answers, one round at a time, until the design tree is fully explored. Ends with a structured decisions digest ready for `/mattstack:spec` to consume. Use when the user says "grill me", "stress-test this plan", "grill this idea", "pre-mortem", "what am I missing", or before starting any non-trivial build.
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

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

## Round format

```
Q1 - <question title>: <question body, might be multiple paragraphs, including multiple choices>

Recommend: <your recommended answer>

---

Q2 - <question title>: <question body>

Recommend: <your recommended answer>
```

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another still open in this round belongs to a _later_ round, not this one.

## Fact-finding vs decisions

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, package versions, existing code), dispatch a sub-agent or run the lookup yourself; don't ask the user for anything you could find out. Don't block on it: a running exploration is an unsettled prerequisite, so only questions downstream of it wait; ask the rest of the frontier now.

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

Every decision from every round belongs in the digest, in the order they settled. If a decision was answered "defer" or "not yet", record it — future spec revisions may return to it.
