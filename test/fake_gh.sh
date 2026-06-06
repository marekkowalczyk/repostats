#!/usr/bin/env bash
# Fake gh CLI for testing. Returns canned JSON responses.
# Supports: gh api repos/OWNER/REPO, gh issue list, gh pr list

set -euo pipefail

REPO_JSON='{
  "stargazers_count": 42,
  "forks_count": 7,
  "subscribers_count": 5,
  "language": "Python",
  "license": { "spdx_id": "MIT" },
  "created_at": "2024-01-15T00:00:00Z",
  "pushed_at": "2026-06-05T12:00:00Z",
  "description": "A test repo",
  "topics": ["cli", "metrics"]
}'

ISSUES_JSON='{"OPEN": 3, "CLOSED": 12}'
PRS_JSON='{"OPEN": 1, "MERGED": 20, "CLOSED": 2}'

case "$1" in
  api)
    echo "$REPO_JSON"
    ;;
  issue)
    echo "$ISSUES_JSON"
    ;;
  pr)
    echo "$PRS_JSON"
    ;;
  *)
    echo "fake_gh: unknown command: $1" >&2
    exit 1
    ;;
esac
