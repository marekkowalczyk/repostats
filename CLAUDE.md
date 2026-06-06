# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

repostats is a single-file Bash CLI tool (`repostats.sh`) that queries the GitHub API for repository metrics and outputs structured markdown or JSON to stdout. It can detect the repo from a git remote or accept an explicit `-r OWNER/REPO` argument.

## Running

```bash
./repostats.sh                          # detect repo from git remote
./repostats.sh -r owner/repo            # specific repo
./repostats.sh -o json                  # JSON output
./repostats.sh -R upstream              # use a different remote
GH=/path/to/gh ./repostats.sh           # override gh binary
```

No build step or linter.

## Testing

```bash
bats test/repostats.bats                # run all tests
bats test/repostats.bats -f "json"      # run tests matching a pattern
```

Tests use `test/fake_gh.sh` (a canned mock of `gh`) via the `GH` env var override. Requires [bats-core](https://github.com/bats-core/bats-core).

## Runtime Dependencies

- `gh` (GitHub CLI, must be authenticated)
- `jq`
- `git` (not needed when `-r` is used)

## Architecture

The script follows a linear pipeline in `repostats.sh`:

1. **Flag parsing** — manual `while/case` loop supporting short and long flags with argument validation
2. **Dependency check** — verifies `jq`, `gh`, and optionally `git` are on PATH
3. **Repo detection** — parses git remote URL (skipped when `-r` is provided)
4. **Data collection** — three `gh` calls: repo metadata, issues (grouped by state), PRs (grouped by state)
5. **Field extraction** — batched `jq` calls with `@tsv` + `read` to minimize subprocesses
6. **Output** — markdown heredoc or `jq -n` for JSON, selected by `-o` flag

Uses `set -euo pipefail`. Distinct exit codes: 0 (ok), 2 (usage), 3 (missing dependency), 4 (no repo), 5 (API failure). API failures for issues/PRs fall back to empty JSON so partial data still produces output; repo API failure is fatal.

## Conventions

- All output goes to stdout; errors go to stderr.
- `-q`/`--quiet` suppresses error messages.
- Missing fields use `// "n/a"` or `// 0` jq fallbacks.
- The `GH` env var allows overriding the `gh` binary path (also used by tests to inject `fake_gh.sh`).
