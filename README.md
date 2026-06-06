# repostats

Pull GitHub metrics for the current repo and output structured markdown to stdout.

## Usage

Run from inside any git repo with a GitHub remote:

```bash
repostats.sh
```

Output is a self-contained markdown section (`## YYYY-MM-DD`) with a metrics table covering stars, forks, issues, PRs, subscribers, language, license, and topics. Designed to be piped, appended, or consumed by other tools.

## Requirements

- [gh](https://cli.github.com/) (GitHub CLI), authenticated
- [jq](https://jqlang.github.io/jq/)
- git

## Install

```bash
# Clone and symlink (or copy) to somewhere on your PATH:
git clone https://github.com/marekkowalczyk/repostats.git
ln -s "$PWD/repostats/repostats.sh" /usr/local/bin/repostats
```

## Example output

```
## 2026-06-06 — owner/repo

> A short repo description

| Metric | Value |
|---|---|
| Stars | 42 |
| Forks | 7 |
| Open issues | 3 |
| Closed issues | 12 |
| Open PRs | 1 |
| Merged PRs | 20 |
| Closed PRs | 2 |
| Subscribers | 5 |
| Language | Python |
| License | MIT |
| Created | 2024-01-15 |
| Last push | 2026-06-05 |

**Topics:** cli, metrics, github
```

## License

MIT
