---
name: review-security
description: Security review of a diff — injection, broken authorization or authentication, leaked secrets, sensitive data exposure, unsafe input handling, weak crypto, risky new dependencies. Every finding traces untrusted input from its source to the dangerous sink. One line per finding, tagged and severity-ranked. Use when the user says "security review", "is this safe", "audit for vulns", or when `/mattstack:review` fans out.
license: MIT
---

# Review — security

Find where the diff lets someone do or see what they should not. A finding names who the attacker is, what they control, and the path from there to the damage.

## Inputs

Default: `git diff <merge-base>...HEAD`. User can supply a range or paste a diff. If not in a git repo, ask. When `/mattstack:review` passes a directory (a temp worktree for a PR or MR), read code and run git there.

Read beyond the diff where it matters: the route or handler that reaches changed code, the middleware in front of it, the auth checks around it, where its output ends up.

## Format

`<file>:L<line>: <tag> <severity>: <what>. Path: <source> → <sink>. <fix>.`

Tags:

- `injection:` untrusted input reaches SQL, a shell, a file path, a template, a query language, or `eval` without parameterisation or escaping.
- `authz:` an action or record is reachable by a user who should not reach it — missing check, check on the wrong object, IDOR.
- `authn:` identity can be faked or skipped — weak session handling, token not verified, auth bypass.
- `secret:` credential, key or token committed, logged, or sent to the client.
- `exposure:` sensitive data in logs, error messages, responses, URLs, or caches it should not be in.
- `input:` untrusted input reaches a risky sink not covered above — SSRF, open redirect, unsafe deserialisation, XXE, unbounded size or regex (ReDoS).
- `crypto:` hand-rolled crypto, weak algorithm, predictable randomness for a secret, missing integrity check.
- `dep:` new or bumped dependency with a known advisory, an unmaintained or typo-squatted package, or install scripts doing network or file work.

Severities:

- `critical:` exploitable by an unauthenticated or low-privilege user, leading to data access, data change, code execution, or account takeover.
- `major:` exploitable but needs a precondition — an authenticated role, a specific config, user interaction.
- `minor:` hardening: defence in depth, information disclosure with little value to an attacker.

Order findings critical first, then major, then minor.

## Check before reporting

Trace each candidate from source to sink. Confirm nothing on the path already neutralises it: framework escaping, an ORM parameterising the query, middleware enforcing auth, a validator. For `dep:`, run the ecosystem's audit (`npm audit`, `pip-audit`, `govulncheck`, `cargo audit`, `dotnet list package --vulnerable`) if it is installed; do not install it.

If the path cannot be confirmed, append `(unverified)` and cap the severity at `major`. An unverified finding never blocks a merge.

Never exploit anything outside the local machine. Never send real credentials or payloads to a live system to prove a finding.

## Examples

`src/api/orders.ts:L34: authz critical: GET /orders/:id returns any order, no owner check. Path: :id from URL → db.orders.find(id). Filter by req.user.id.`

`app/search.py:L18: injection critical: f-string builds SQL from q. Path: ?q= → cursor.execute(sql). Pass q as a parameter.`

`src/log/request.go:L52: exposure major: logs full request headers including Authorization. Path: incoming request → access log. Redact Authorization and Cookie.`

`config/settings.rb:L9: secret critical: Stripe live key committed. Path: repo → anyone with read access. Rotate the key; load from env.`

`package.json:L31: dep major: adds left-pad-utils 0.0.3, published last week, postinstall fetches a remote script. Drop it; the code needs String.prototype.padStart.`

## End line

```
security: <critical> critical, <major> major, <minor> minor. <unverified> unverified.
```

If nothing found: `security: no issues found. Ship.`

## Boundaries

Scope: what an attacker can do through this diff. Bugs with no attacker are `/mattstack:review-correctness`'s. Spec, complexity and abstraction cost belong to the other specialists. Does not apply fixes; only lists them. A finding that needs a secret rotated says so in the fix — rotation is the user's job, never done here.
