# Next Session

## Strategic direction (from 2026-06-06 assessment)

The project is well-crafted but has limited appeal beyond personal use — the data it surfaces is already available via `gh repo view` or the GitHub web UI. To grow beyond a personal utility, consider these differentiators (in priority order):

1. **Time-series tracking** — store snapshots, show deltas ("gained 12 stars this week"). Simplest feature that most clearly separates repostats from `gh repo view`.
2. **Multi-repo comparison** — side-by-side table of several repos
3. **Deeper metrics** — median time-to-close, PR review turnaround, contributor count, commit frequency
4. **CI/release integration** — auto-post stats to PRs or release notes

Competitors to be aware of: ossinsight.io, star-history.com, repobeats, various `gh` extensions, mergestat.

## Existing backlog

- Investigate the `--limit 1000` truncation for repos with >1000 issues/PRs — consider `gh api` with pagination or at minimum document the limitation
- Consider adding a `--date` flag to override the default `date +%Y-%m-%d` (useful for backdating reports)
