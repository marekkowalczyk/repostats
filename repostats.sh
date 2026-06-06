#!/usr/bin/env bash
# repostats — pull GitHub metrics for a repo, output structured markdown or
# JSON to stdout.
#
# Usage: repostats [-r|--repo OWNER/REPO] [-R|--remote REMOTE]
#                  [-o|--output FORMAT] [-q|--quiet] [-h|--help] [-V|--version]
#
# Requires: gh (GitHub CLI, authenticated), jq, git (unless -r is used)

set -euo pipefail

VERSION="1.0.0"
GH="${GH:-gh}"
REMOTE_NAME="origin"
OUTPUT_FORMAT="markdown"
QUIET=0
FULL_REPO=""

# --- Exit codes ---
EX_OK=0
EX_USAGE=2
EX_DEPENDENCY=3
EX_NO_REPO=4
EX_API=5

usage() {
  cat <<EOF
Usage: repostats [-r|--repo OWNER/REPO] [-R|--remote REMOTE]
                 [-o|--output FORMAT] [-q|--quiet] [-h|--help] [-V|--version]

Pull GitHub metrics for a repository and output structured data.

Options:
  -r, --repo OWNER/REPO   Query a specific repo instead of detecting from git remote
  -R, --remote REMOTE      Git remote name to use (default: origin)
  -o, --output FORMAT      Output format: markdown (default) or json
  -q, --quiet              Quiet mode: suppress error messages
  -h, --help               Show this help
  -V, --version            Show version

Environment:
  GH                       Path to gh binary (default: gh)

Examples:
  repostats                              # current repo
  repostats -r torvalds/linux            # specific repo
  repostats --output json | jq .stars    # JSON output
  repostats --remote upstream            # use 'upstream' remote
EOF
  exit "$EX_OK"
}

err() {
  [[ "$QUIET" -eq 1 ]] && return
  echo "ERROR: $*" >&2
}

need_arg() {
  if [[ -z "${2:-}" || "${2:-}" == -* ]]; then
    err "Option $1 requires an argument"
    exit "$EX_USAGE"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -r|--repo)     need_arg "$1" "${2:-}"; FULL_REPO="$2"; shift 2 ;;
    -R|--remote)   need_arg "$1" "${2:-}"; REMOTE_NAME="$2"; shift 2 ;;
    -o|--output)   need_arg "$1" "${2:-}"; OUTPUT_FORMAT="$2"; shift 2 ;;
    -q|--quiet)    QUIET=1; shift ;;
    -h|--help)     usage ;;
    -V|--version)  echo "repostats $VERSION"; exit "$EX_OK" ;;
    --)            shift; break ;;
    -*)            err "Unknown option: $1"; exit "$EX_USAGE" ;;
    *)             err "Unexpected argument: $1"; exit "$EX_USAGE" ;;
  esac
done

if [[ $# -gt 0 ]]; then
  err "Unexpected argument: $1"
  exit "$EX_USAGE"
fi

if [[ "$OUTPUT_FORMAT" != "markdown" && "$OUTPUT_FORMAT" != "json" ]]; then
  err "Unknown format: $OUTPUT_FORMAT (expected: markdown, json)"
  exit "$EX_USAGE"
fi

# --- Check dependencies ---
deps=("jq" "$GH")
[[ -z "$FULL_REPO" ]] && deps+=("git")
for cmd in "${deps[@]}"; do
  command -v "$cmd" >/dev/null 2>&1 || {
    err "Required command not found: $cmd"
    exit "$EX_DEPENDENCY"
  }
done

# --- Detect repo ---
if [[ -z "$FULL_REPO" ]]; then
  REMOTE_URL=$(git remote get-url "$REMOTE_NAME" 2>/dev/null) || {
    err "Not in a git repo or no '$REMOTE_NAME' remote."
    exit "$EX_NO_REPO"
  }

  if [[ "$REMOTE_URL" =~ github\.com[:/]([^/]+)/([^/.]+)(\.git)?$ ]]; then
    FULL_REPO="${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
  else
    err "Could not parse GitHub owner/repo from: $REMOTE_URL"
    exit "$EX_NO_REPO"
  fi
fi

# --- Pull data (repo, issues, PRs) ---
REPO_JSON=$($GH api "repos/$FULL_REPO" 2>&1) || {
  err "gh api failed: $REPO_JSON"
  exit "$EX_API"
}

# Issues/PRs: fall back to empty JSON on failure so partial output is still useful.
ISSUES_JSON=$($GH issue list --repo "$FULL_REPO" --state all --limit 1000 \
  --json state --jq 'group_by(.state) | map({(.[0].state): length}) | add // {}' 2>/dev/null) || ISSUES_JSON='{}'

PRS_JSON=$($GH pr list --repo "$FULL_REPO" --state all --limit 1000 \
  --json state --jq 'group_by(.state) | map({(.[0].state): length}) | add // {}' 2>/dev/null) || PRS_JSON='{}'

# --- Extract fields ---
read -r STARS FORKS SUBSCRIBERS LANGUAGE LICENSE CREATED PUSHED <<< \
  "$(echo "$REPO_JSON" | jq -r '[
    .stargazers_count,
    .forks_count,
    .subscribers_count,
    (.language // "n/a"),
    (.license.spdx_id // "n/a"),
    (.created_at | split("T")[0]),
    (.pushed_at | split("T")[0])
  ] | @tsv')"
DESCRIPTION=$(echo "$REPO_JSON" | jq -r '.description // "n/a"')
TOPICS=$(echo "$REPO_JSON" | jq -r '(.topics // []) | join(", ")')

read -r ISSUES_OPEN ISSUES_CLOSED <<< \
  "$(echo "$ISSUES_JSON" | jq -r '[(.OPEN // 0), (.CLOSED // 0)] | @tsv')"
read -r PRS_OPEN PRS_MERGED PRS_CLOSED <<< \
  "$(echo "$PRS_JSON" | jq -r '[(.OPEN // 0), (.MERGED // 0), (.CLOSED // 0)] | @tsv')"

TODAY=$(date +%Y-%m-%d)

# --- Output ---
if [[ "$OUTPUT_FORMAT" == "json" ]]; then
  jq -n \
    --arg repo "$FULL_REPO" \
    --arg date "$TODAY" \
    --arg desc "$DESCRIPTION" \
    --argjson stars "$STARS" \
    --argjson forks "$FORKS" \
    --argjson subscribers "$SUBSCRIBERS" \
    --arg language "$LANGUAGE" \
    --arg license "$LICENSE" \
    --arg created "$CREATED" \
    --arg pushed "$PUSHED" \
    --argjson issues_open "$ISSUES_OPEN" \
    --argjson issues_closed "$ISSUES_CLOSED" \
    --argjson prs_open "$PRS_OPEN" \
    --argjson prs_merged "$PRS_MERGED" \
    --argjson prs_closed "$PRS_CLOSED" \
    --arg topics "$TOPICS" \
    '{
      repo: $repo,
      date: $date,
      description: $desc,
      stars: $stars,
      forks: $forks,
      subscribers: $subscribers,
      language: $language,
      license: $license,
      created: $created,
      last_push: $pushed,
      issues: { open: $issues_open, closed: $issues_closed },
      prs: { open: $prs_open, merged: $prs_merged, closed: $prs_closed },
      topics: ($topics | if . == "" then [] else split(", ") end)
    }'
else
  cat <<EOF
## $TODAY — $FULL_REPO

> $DESCRIPTION

| Metric | Value |
|---|---|
| Stars | $STARS |
| Forks | $FORKS |
| Open issues | $ISSUES_OPEN |
| Closed issues | $ISSUES_CLOSED |
| Open PRs | $PRS_OPEN |
| Merged PRs | $PRS_MERGED |
| Closed PRs | $PRS_CLOSED |
| Subscribers | $SUBSCRIBERS |
| Language | $LANGUAGE |
| License | $LICENSE |
| Created | $CREATED |
| Last push | $PUSHED |

$([ -n "$TOPICS" ] && echo "**Topics:** $TOPICS" || echo "**Topics:** —")
EOF
fi
