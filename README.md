# repostats

Pull GitHub metrics for a repository and output structured markdown or JSON to stdout.

## Usage

```bash
repostats                              # current repo (detects from git remote)
repostats -r torvalds/linux            # specific repo
repostats --output json | jq .stars    # JSON output
repostats --remote upstream            # use 'upstream' remote instead of 'origin'
repostats -q                           # suppress error messages
```

Output is a self-contained markdown section (`## YYYY-MM-DD`) with a metrics table covering stars, forks, issues, PRs, subscribers, language, license, and topics. Designed to be piped, appended, or consumed by other tools.

## Options

| Short | Long | Description |
|---|---|---|
| `-r` | `--repo OWNER/REPO` | Query a specific repo instead of detecting from git remote |
| `-R` | `--remote REMOTE` | Git remote name to use (default: `origin`) |
| `-o` | `--output FORMAT` | Output format: `markdown` (default) or `json` |
| `-q` | `--quiet` | Quiet mode: suppress error messages |
| `-h` | `--help` | Show help |
| `-V` | `--version` | Show version |

The `GH` environment variable overrides the path to the `gh` binary.

## Requirements

- [gh](https://cli.github.com/) (GitHub CLI), authenticated
- [jq](https://jqlang.github.io/jq/)
- git (not needed when using `-r`)

## Install

```bash
# Clone and symlink (or copy) to somewhere on your PATH:
git clone https://github.com/marekkowalczyk/repostats.git
ln -s "$PWD/repostats/repostats.sh" /usr/local/bin/repostats
```

## Example output

### Markdown (default)

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

### JSON (`-o json`)

```json
{
  "repo": "owner/repo",
  "date": "2026-06-06",
  "description": "A short repo description",
  "stars": 42,
  "forks": 7,
  "subscribers": 5,
  "language": "Python",
  "license": "MIT",
  "created": "2024-01-15",
  "last_push": "2026-06-05",
  "issues": { "open": 3, "closed": 12 },
  "prs": { "open": 1, "merged": 20, "closed": 2 },
  "topics": ["cli", "metrics", "github"]
}
```

## Testing

```bash
bats test/repostats.bats
```

Requires [bats-core](https://github.com/bats-core/bats-core).

## License

MIT
