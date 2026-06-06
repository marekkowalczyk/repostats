#!/usr/bin/env bats
# Tests for repostats.sh
#
# Run: bats test/repostats.bats
# Requires: bats-core

SCRIPT="$BATS_TEST_DIRNAME/../repostats.sh"
FAKE_GH="$BATS_TEST_DIRNAME/fake_gh.sh"

# ── Help & version ──────────────────────────────────────────────

@test "-h prints usage and exits 0" {
  run "$SCRIPT" -h
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == Usage:* ]]
}

@test "--help prints usage and exits 0" {
  run "$SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == Usage:* ]]
}

@test "-V prints version and exits 0" {
  run "$SCRIPT" -V
  [ "$status" -eq 0 ]
  [[ "$output" == repostats\ * ]]
}

@test "--version prints version and exits 0" {
  run "$SCRIPT" --version
  [ "$status" -eq 0 ]
  [[ "$output" == repostats\ * ]]
}

# ── Argument validation ─────────────────────────────────────────

@test "unknown short flag exits 2" {
  run "$SCRIPT" -z
  [ "$status" -eq 2 ]
  [[ "$output" == *"Unknown option"* ]]
}

@test "unknown long flag exits 2" {
  run "$SCRIPT" --bogus
  [ "$status" -eq 2 ]
  [[ "$output" == *"Unknown option"* ]]
}

@test "unexpected positional arg exits 2" {
  run "$SCRIPT" something
  [ "$status" -eq 2 ]
  [[ "$output" == *"Unexpected argument"* ]]
}

@test "-r without value exits 2" {
  run "$SCRIPT" -r
  [ "$status" -eq 2 ]
  [[ "$output" == *"requires an argument"* ]]
}

@test "--repo without value exits 2" {
  run "$SCRIPT" --repo
  [ "$status" -eq 2 ]
  [[ "$output" == *"requires an argument"* ]]
}

@test "-o without value exits 2" {
  run "$SCRIPT" -o
  [ "$status" -eq 2 ]
  [[ "$output" == *"requires an argument"* ]]
}

@test "--output without value exits 2" {
  run "$SCRIPT" --output
  [ "$status" -eq 2 ]
  [[ "$output" == *"requires an argument"* ]]
}

@test "-R without value exits 2" {
  run "$SCRIPT" -R
  [ "$status" -eq 2 ]
  [[ "$output" == *"requires an argument"* ]]
}

@test "invalid output format exits 2" {
  run "$SCRIPT" -o xml
  [ "$status" -eq 2 ]
  [[ "$output" == *"Unknown format"* ]]
}

@test "invalid long output format exits 2" {
  run "$SCRIPT" --output csv
  [ "$status" -eq 2 ]
  [[ "$output" == *"Unknown format"* ]]
}

# ── Quiet mode ──────────────────────────────────────────────────

@test "-q suppresses error output" {
  run "$SCRIPT" -q --bogus
  [ "$status" -eq 2 ]
  [ -z "$output" ]
}

@test "--quiet suppresses error output" {
  run "$SCRIPT" --quiet -z
  [ "$status" -eq 2 ]
  [ -z "$output" ]
}

# ── -- separator ────────────────────────────────────────────────

@test "-- stops flag parsing" {
  run "$SCRIPT" -- --help
  # --help after -- is treated as a positional arg, not a flag
  [ "$status" -eq 2 ]
  [[ "$output" == *"Unexpected argument"* ]]
}

# ── Markdown output with fake gh ─────────────────────────────────

@test "markdown output contains expected fields" {
  GH="$FAKE_GH" run "$SCRIPT" -r test/owner
  [ "$status" -eq 0 ]
  [[ "$output" == *"test/owner"* ]]
  [[ "$output" == *"| Stars"*"42 |"* ]]
  [[ "$output" == *"| Forks"*"7 |"* ]]
  [[ "$output" == *"| Open issues"*"3 |"* ]]
  [[ "$output" == *"| Closed issues"*"12 |"* ]]
  [[ "$output" == *"| Open PRs"*"1 |"* ]]
  [[ "$output" == *"| Merged PRs"*"20 |"* ]]
  [[ "$output" == *"| Closed PRs"*"2 |"* ]]
  [[ "$output" == *"| Subscribers"*"5 |"* ]]
  [[ "$output" == *"| Language"*"| Python"*"|"* ]]
  [[ "$output" == *"| License"*"| MIT"*"|"* ]]
  [[ "$output" == *"| Created"*"| 2024-01-15"*"|"* ]]
  [[ "$output" == *"| Last push"*"| 2026-06-05"*"|"* ]]
  [[ "$output" == *"A test repo"* ]]
  [[ "$output" == *"cli, metrics"* ]]
}

@test "markdown output starts with dated heading" {
  GH="$FAKE_GH" run "$SCRIPT" -r test/owner
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" =~ ^##\ [0-9]{4}-[0-9]{2}-[0-9]{2}\ —\ test/owner$ ]]
}

# ── JSON output with fake gh ─────────────────────────────────────

@test "json output is valid JSON" {
  GH="$FAKE_GH" run "$SCRIPT" -r test/owner -o json
  [ "$status" -eq 0 ]
  echo "$output" | jq . >/dev/null 2>&1
}

@test "json output contains expected values" {
  GH="$FAKE_GH" run "$SCRIPT" -r test/owner --output json
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq -r '.repo')" = "test/owner" ]
  [ "$(echo "$output" | jq '.stars')" = "42" ]
  [ "$(echo "$output" | jq '.forks')" = "7" ]
  [ "$(echo "$output" | jq '.subscribers')" = "5" ]
  [ "$(echo "$output" | jq -r '.language')" = "Python" ]
  [ "$(echo "$output" | jq -r '.license')" = "MIT" ]
  [ "$(echo "$output" | jq -r '.created')" = "2024-01-15" ]
  [ "$(echo "$output" | jq -r '.last_push')" = "2026-06-05" ]
  [ "$(echo "$output" | jq -r '.description')" = "A test repo" ]
  [ "$(echo "$output" | jq '.issues.open')" = "3" ]
  [ "$(echo "$output" | jq '.issues.closed')" = "12" ]
  [ "$(echo "$output" | jq '.prs.open')" = "1" ]
  [ "$(echo "$output" | jq '.prs.merged')" = "20" ]
  [ "$(echo "$output" | jq '.prs.closed')" = "2" ]
}

@test "json topics is an array" {
  GH="$FAKE_GH" run "$SCRIPT" -r test/owner -o json
  [ "$status" -eq 0 ]
  [ "$(echo "$output" | jq '.topics | length')" = "2" ]
  [ "$(echo "$output" | jq -r '.topics[0]')" = "cli" ]
  [ "$(echo "$output" | jq -r '.topics[1]')" = "metrics" ]
}

# ── No repo detection when -r is used ───────────────────────────

@test "-r skips git remote detection" {
  # Run from /tmp which has no git repo — should still work with -r
  cd /tmp
  GH="$FAKE_GH" run "$SCRIPT" -r test/owner
  [ "$status" -eq 0 ]
  [[ "$output" == *"test/owner"* ]]
}

# ── Exit codes ──────────────────────────────────────────────────

@test "missing remote exits 4" {
  cd /tmp
  run "$SCRIPT"
  [ "$status" -eq 4 ]
}

@test "missing dependency exits 3" {
  GH="/nonexistent/gh" run "$SCRIPT" -r test/owner
  [ "$status" -eq 3 ]
  [[ "$output" == *"not found"* ]]
}
