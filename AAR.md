# After Action Review

Continuous improvement log. Each session ends with a brief review: what went well, what didn't, what to change. This is the POOGI (Process Of Ongoing Improvement) record for this project.

## 2026-06-06 — Extract repostats.sh to standalone repo

**What went well:**
- Clean extraction — script moved, breathe CLAUDE.md updated, GitHub repo created and pushed in one flow
- Caught the wrong GitHub username early thanks to user correction

**What didn't go well:**
- Used wrong GitHub username (`kowalczykm` instead of `marekkowalczyk`) in the README — should have checked existing repos or the git config first
- Tried to `git add` a file that was already staged by `git rm`, causing a failed commit attempt

**What we'll do differently:**
- Check `gh api user` or existing repo URLs before guessing GitHub usernames
- After `git rm`, remember the file is already staged — just add any other changed files

## 2026-06-06 — Code review, CLI flags, tests, and v1.0.0 release

**What went well:**
- Systematic code review led to a clean, prioritized improvement plan — every fix flowed from the review
- Incremental approach worked well: fix bugs first, then add flags, then tests, then release
- bats-core test suite with `fake_gh.sh` mock proved the `GH` env var design pays off for testability
- All 25 tests passed on first run; the test/mock pattern is clean and reusable
- Documentation stayed consistent across three surfaces (--help, README, CLAUDE.md) by updating them together

**What didn't go well:**
- `gh` CLI broken in Claude Code's Bash tool due to shell profile pollution — wasted several attempts before discovering the `env -i` workaround
- `brew install` failed due to old macOS (10.14.6) — had to fall back to cloning bats-core from source, then `install.sh` failed on permissions; ended up running from `/tmp`
- Heredoc-style `--notes` argument to `gh release create` also failed due to the same shell profile issue

**What we'll do differently:**
- For this machine: use `env -i` prefix when invoking `gh` directly from Claude Code until the shell profile issue is fixed (tracked in `~/repos/system/owner-inbox/2026-06-06-gh-cli-bash-shell-error.md`)
- When brew is unavailable, clone tools to a persistent location (not `/tmp`) and install with `sudo`
