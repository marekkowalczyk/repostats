# Next Session

- Investigate the `--limit 1000` truncation for repos with >1000 issues/PRs — consider `gh api` with pagination or at minimum document the limitation
- Consider adding a `--date` flag to override the default `date +%Y-%m-%d` (useful for backdating reports)
- Explore multi-repo support: accept a file of `OWNER/REPO` lines and produce a combined report
