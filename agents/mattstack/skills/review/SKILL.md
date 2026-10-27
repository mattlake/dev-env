---
name: review
description: Full-stack review of a diff — the current branch, a range, a branch name, or a GitHub PR / GitLab MR link. Fans out in parallel to `review-spec` (does the code match the spec?), `review-correctness` (what breaks?), `review-security` (what can an attacker do?), `review-performance` (will it scale?), `review-lazy` (what can we delete?), and `review-abstraction` (do new seams earn their keep?). Aggregates a single report. Never posts to the PR. Use when the user says "review this", "review the diff", "review my branch", "review the PR", "review this MR", or pastes a PR or MR link.
license: MIT
---

# Review — orchestrator

Resolve what to review, run the six specialist reviewers in parallel forks against the same diff, aggregate their outputs, and print one report.

## Target

Work out which of these the user gave:

1. **Nothing** → current branch: `git diff <merge-base>...HEAD`, where the merge-base is taken against the remote's default branch. Code is read from the working tree.
2. **A range or a pasted diff** → use it as given.
3. **A branch name** → fetch it from the remote if it is not local; diff it against its merge-base with the default branch.
4. **A PR or MR** → see below.

If not in a git repo and the target is not a PR or MR link, ask.

### PR or MR

Accept a URL or a bare number (`#123`, `!123`, `123`) for the current repo.

Find the ref from the URL path. Plain git fetches these from any host that publishes them, no CLI or API needed:

| URL path | Ref |
|---|---|
| `/pull/<n>` (GitHub) | `refs/pull/<n>/head` |
| `/-/merge_requests/<n>` (GitLab, including self-hosted) | `refs/merge-requests/<n>/head` |
| `/pulls/<n>` (Gitea, Forgejo) | `refs/pull/<n>/head` |

A bare number: `!` means GitLab, `#` means GitHub; otherwise infer from the remote's host, and ask if still unclear. Any other host, or a ref the fetch rejects → ask the user for the source branch name and treat it as target 3.

Steps:

1. **Remote.** Pick the remote in `git remote -v` whose URL has the same host and project path. If none matches, or not in a git repo, `git clone --filter=blob:none` the project into a temp directory and use that clone.
2. **Metadata, optional.** If the host's CLI is installed and authenticated — `gh pr view <n> --json title,body,baseRefName,headRefName,closingIssuesReferences` for GitHub, `glab mr view <n> -F json` for GitLab — read the title, description, target branch, source branch and linked issues. Otherwise the target branch is the remote's default (`git ls-remote --symref <remote> HEAD`) and there is no description. Never call a host's API directly.
3. **Fetch.** `git fetch <remote> <ref>` and record the SHA from `FETCH_HEAD`; then `git fetch <remote> <target branch>` and record that SHA. Create no local branches.
4. **Worktree.** `git worktree add --detach <temp dir> <head SHA>`. The user's checkout is never switched, stashed or touched.
5. **Diff.** `git diff <target SHA>...<head SHA>`.

When the report is printed, `git worktree remove --force <temp dir>`, and delete any temp clone.

## Spec

In order, use the first that exists:

1. A spec path the user supplied.
2. `~/.claude/specs/<repo>/<slug>.md`, where `<repo>` is the basename of the main checkout's top level: the one whose slug matches the branch under review (the PR or MR's source branch), or the only one if just one exists. Ignore `*.state.md`, `*.digest.md` and `*.verify.md`, which `/mattstack:run` keeps alongside.
3. For a PR or MR: its title, description and linked issues, written to a temp file headed `# Intent from <PR|MR> <n> (not a spec)`.
4. Nothing → skip `review-spec` and note the omission in the report.

Several specs and none matches the branch → ask which.

## Fan-out

Spawn six parallel sub-agents (one per specialist skill). Each gets the same diff, and the directory to read code and run git in: the worktree for a PR or MR, the working tree otherwise. `review-spec` also gets the spec. Wait for all six to return.

- Fork 1 → invoke `/mattstack:review-spec`
- Fork 2 → invoke `/mattstack:review-correctness`
- Fork 3 → invoke `/mattstack:review-security`
- Fork 4 → invoke `/mattstack:review-performance`
- Fork 5 → invoke `/mattstack:review-lazy`
- Fork 6 → invoke `/mattstack:review-abstraction`

Fan-out uses parallel tool calls in one message. Do not run serially — the whole point of the orchestrator is wall-clock speed.

## Aggregated report

Print in this order:

```
## Review — <branch, range, or PR/MR title and link>

### Spec conformance
<verbatim output from review-spec, or "skipped: no spec found">

### Correctness
<verbatim output from review-correctness>

### Security
<verbatim output from review-security>

### Performance
<verbatim output from review-performance>

### Laziness
<verbatim output from review-lazy>

### Abstraction cost
<verbatim output from review-abstraction>

### Verdict

<one line, per rules below>
```

## Verdict rule

- Any `critical` from `review-spec`, `review-correctness`, `review-security` or `review-performance`, or any `violates` → `verdict: block. Fix critical findings before merge.`
- Any `major` from those four, OR a `net -N` from `review-lazy` where N is more than 20% of added lines → `verdict: revise. <one-line summary of the top pressure>.`
- Otherwise → `verdict: ship.`

## Boundaries

- Does not apply fixes.
- Never comments on, approves, or changes the state of a PR or MR. The report is printed locally only.
- Never switches, stashes, or writes to the user's checkout. Everything fetched for a PR or MR lives in a temp worktree that is removed afterwards.
- Deduplication is not needed: each specialist has a distinct scope, so a finding from two of them is signal, not noise.
