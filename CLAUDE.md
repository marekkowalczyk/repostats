# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

repostats is a single-file Bash CLI tool (`repostats.sh`) that queries the GitHub API for the current repository's metrics and outputs a structured markdown section to stdout. It is run from inside any git repo with a GitHub `origin` remote.

## Running

```bash
./repostats.sh            # run directly
GH=/path/to/gh ./repostats.sh  # override gh binary
```

No build step or linter. The project is a single shell script.

## Testing

```bash
bats test/repostats.bats          # run all tests
bats test/repostats.bats -f "json"  # run tests matching a pattern
```

Tests use `test/fake_gh.sh` (a canned mock of `gh`) via the `GH` env var override. Requires [bats-core](https://github.com/bats-core/bats-core).

## Runtime Dependencies

- `gh` (GitHub CLI, must be authenticated)
- `jq`
- `git`

## Architecture

The script follows a linear pipeline in `repostats.sh`:

1. **Remote detection** — parses `git remote get-url origin` to extract GitHub `OWNER/REPO`
2. **Data collection** — three API calls via `gh`: repo metadata, issues (grouped by state), PRs (grouped by state)
3. **Field extraction** — `jq` pulls individual metrics from JSON responses
4. **Output** — a heredoc emits a dated markdown section with a metrics table

Uses `set -euo pipefail`. API failures for issues/PRs fall back to empty JSON (`'{}'`) so partial data still produces output; repo API failure is fatal.

## Conventions

- All output goes to stdout; errors go to stderr.
- Missing fields use `// "n/a"` or `// 0` jq fallbacks.
- The `GH` env var allows overriding the `gh` binary path.
