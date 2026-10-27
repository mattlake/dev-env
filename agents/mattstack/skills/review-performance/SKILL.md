---
name: review-performance
description: Performance review of a diff, limited to costs that grow with data — N+1 queries, quadratic work on unbounded input, loading everything into memory, blocking calls on hot or async paths, missing pagination or indexes. Every finding names the scale at which it hurts. No micro-optimisation. One line per finding, tagged and severity-ranked. Use when the user says "performance review", "will this scale", "is this slow", or when `/mattstack:review` fans out.
license: MIT
---

# Review — performance

Find where the diff's cost grows with data the code does not control. If the cost stays flat as data grows, it is not a finding.

## Inputs

Default: `git diff <merge-base>...HEAD`. User can supply a range or paste a diff. If not in a git repo, ask. When `/mattstack:review` passes a directory (a temp worktree for a PR or MR), read code and run git there.

Read beyond the diff where cost hides: the loop around a changed call, the query a repository method runs, the schema and migrations for any table the diff queries, whether the input is bounded upstream (pagination, validation, a fixed-size config).

## Format

`<file>:L<line>: <tag> <severity>: <what>. Scale: <input size → cost>. <fix>.`

Tags:

- `n+1:` a query, request or file read per item inside a loop.
- `quadratic:` nested iteration, repeated linear search, or repeated string or array building over input with no upper bound.
- `unbounded:` loads a whole table, file, response or result set into memory, or returns it without pagination.
- `blocking:` synchronous I/O, sleep or CPU-heavy work on a request path, event loop, UI thread or async context.
- `index:` a new query filters or sorts on columns no index covers.
- `repeat:` the same expensive work redone inside a loop or per request when its inputs have not changed.

Severities:

- `critical:` input a user or external system controls can grow without limit, on a request path — this is an outage waiting for traffic.
- `major:` grows with ordinary production data and will be noticed — slow pages, timeouts at realistic sizes.
- `minor:` grows, but the input is bounded small in practice.

Order findings critical first, then major, then minor.

## Check before reporting

Name the scale with a number from the code or data: the page size, the config limit, the table's expected row count, the bound on the request body. If no bound exists, say so — that is the finding.

Where cheap, measure: a throwaway benchmark or script in a temp directory outside the repo, timing the code at two input sizes, or `EXPLAIN` against a local database. Edit nothing in the repo.

If the cost cannot be shown from the code or a measurement, append `(unverified)` and cap the severity at `major`. An unverified finding never blocks a merge.

## Examples

`src/api/orders.ts:L40: n+1 critical: loads customer per order inside map(). Scale: /orders has no page limit, 10k orders → 10k queries. Join or batch-load customers by id.`

`app/reports/export.py:L22: unbounded major: Invoice.objects.all() into a list before writing CSV. Scale: 2M rows in prod → whole table in memory. Stream with iterator() and write rows as they arrive.`

`src/search/match.go:L71: quadratic major: slices.Contains inside loop over results. Scale: 5k results × 5k tags → 25M comparisons. Build a map of tags first.`

`src/handlers/upload.js:L15: blocking major: fs.readFileSync on the request path. Scale: 50MB uploads stall the event loop for every request. Use fs.promises or a stream.`

`db/migrate/20261027_add_status.rb:L4: index minor: orders filtered by status, no index. Scale: 40k rows today, query under 10ms (unverified). Add an index once the table passes ~1M.`

## End line

```
performance: <critical> critical, <major> major, <minor> minor. <unverified> unverified.
```

If nothing found: `performance: scales fine. Ship.`

## Boundaries

Scope: cost that grows with data. Not constant-factor tuning, allocation counting or micro-benchmarks on bounded input — that is complexity, and `/mattstack:review-lazy` would flag the extra code. Bugs are `/mattstack:review-correctness`'s, deliberately crafted payloads (ReDoS, zip bombs, oversized bodies) are `/mattstack:review-security`'s `input:`. Growth from ordinary use stays here. Does not apply fixes; only lists them.
