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
