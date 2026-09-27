---
name: review-abstraction
description: For every new abstraction in a diff — interface, base class, wrapper, indirection layer, generic type — decide whether it earns its keep or should be inlined. One line per abstraction with a verdict. Use when the user says "review abstractions", "does this abstraction earn its keep", "is this indirection worth it", or when `/mattstack:review` fans out.
license: MIT
---

# Review — abstraction cost

Every new abstraction in the diff gets audited. Does it pay for itself, or does it add cost the code cannot yet cash?

An abstraction is anything that separates a concept from its use: an interface, a base class, a wrapper, a strategy object, a generic type, a hook, a middleware, a dependency-injection seam, a new module boundary.

## The test

For each abstraction, answer:

1. **How many concrete implementations exist right now, in this diff or the codebase?**
2. **What real (not speculative) callers force this seam to exist?**
3. **What breaks if it is inlined?**

Verdicts:

- `keep:` two or more implementations exist, or a concrete caller genuinely needs the seam (test-double, plugin surface, boundary crossing). Explain in five words.
- `inline:` one implementation, one caller, no boundary crossed. Recommend deleting the seam and inlining.
- `defer:` seam is speculative — "we might have another backend". Recommend removing until the second implementation lands.
- `wrong-shape:` seam exists but sits in the wrong place — leaks details the caller shouldn't know, or hides details the caller must know. Name the better seam.

## Format

`<file>:L<line>: <verdict> <what>. <reason or replacement>.`

## Examples

`src/repo/user.py:L12: inline UserRepository interface. One implementation (SqlUserRepository), one caller (UserService). Inline the two methods into UserService.`

`src/plugin/loader.py:L44: keep PluginHost. Three concrete plugins already ship. Seam earns its keep.`

`src/http/client.py:L88: defer AbstractHttpClient. Only ApiClient exists. Real requests-based mock in tests already works via monkeypatch. Delete until a second client arrives.`

`src/checkout/payment.py:L30: wrong-shape PaymentGateway.charge(amount, currency, meta). Callers pass currency="USD" everywhere; meta is unused. Narrow to `charge(amount_usd_cents)` until multi-currency is real.`

## Inputs

Default: `git diff <merge-base>...HEAD`. User can supply a range or paste a diff. If not in a git repo, ask.

## End line

```
abstraction: <keep> keep, <inline> inline, <defer> defer, <wrong-shape> wrong-shape.
```

If nothing new to audit: `abstraction: no new seams. Ship.`

## Boundaries

Scope: new abstractions introduced in this diff. Do not audit pre-existing abstractions unless the diff extends them. Do not apply fixes; only list them. Complexity elsewhere in the diff (dead code, reinvented stdlib) is `/mattstack:review-lazy`'s job — do not double-report.

Before resting a finding on a claim about performance, allocation, or how a tool or library behaves, check it: run a benchmark, `-gcflags=-m`, a quick script, or read the source. If you can't check it, label the finding `(unverified)`. A reason that turns out false is worse than no reason.
