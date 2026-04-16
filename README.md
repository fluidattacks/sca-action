# Fluid Attacks SCA

Free, open-source software composition analysis (SCA) action for your GitHub repositories. No account, API key, or registration required.

Scans your project dependencies for known vulnerabilities automatically on every push and pull request.

## Quick Start (2 minutes)

### 1. Create the configuration file

Add a file called `.sca.yaml` in the root of your repository:

```yaml
language: EN
strict: false
output:
  file_path: results.sarif
  format: SARIF
sca:
  include:
    - .
```

### 2. Create the GitHub Actions workflow

Add the file `.github/workflows/sca.yml` to your repository:

```yaml
name: SCA
on:
  push:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: fluidattacks/sca-action@1.0.0
        id: scan
```

Commit both files, push, and the scan will run automatically.

## How it works

### Default branch detection

The action automatically detects your repository's default branch. It works with any branch name — `main`, `master`, `trunk`, `develop`, or whatever your team uses.

### Scan types

| Trigger | Scan type | What it analyzes |
|---|---|---|
| Push to default branch | Full scan | All dependencies in the repository |
| Push to any other branch | Differential scan | Only changed files vs. default branch |
| Pull request | Differential scan | Only changed files vs. PR base branch |

### Why `fetch-depth: 0`?

The `actions/checkout` step uses `fetch-depth: 0` to download the full git history. This is necessary for the differential scan to compare your current changes against the default branch.

## Configuration reference

All settings go in `.sca.yaml` at the root of your repository.

### Minimal configuration

```yaml
language: EN
strict: false
output:
  file_path: results.sarif
  format: SARIF
sca:
  include:
    - .
```

### Full configuration example

```yaml
# Language for vulnerability descriptions: EN or ES
language: EN

# If true, the pipeline fails when vulnerabilities are found
strict: false

output:
  # Path where the results file will be written
  file_path: results.sarif
  # Format: SARIF, CSV, or ALL
  format: SARIF

sca:
  # Paths to include in the scan (relative to repo root)
  include:
    - .
  # Paths to exclude from the scan
  exclude:
    - vendor/
```

### Configuration options

| Option | Required | Default | Description |
|---|---|---|---|
| `language` | No | `EN` | Language for descriptions (`EN` or `ES`) |
| `strict` | No | `false` | Fail the pipeline if vulnerabilities are found |
| `output.file_path` | Yes | — | Path for the output file |
| `output.format` | Yes | — | Output format: `SARIF`, `CSV`, or `ALL` |
| `sca.include` | Yes | — | List of paths to scan |
| `sca.exclude` | No | — | List of paths to exclude |

## Action outputs

| Output | Description |
|---|---|
| `sarif_file` | Path to the SARIF results file (when format is `SARIF` or `ALL`) |
| `vulnerabilities_found` | `true` if any vulnerabilities were detected, `false` otherwise |

## Troubleshooting

### The scan runs but no results appear in the Security tab

Make sure the "Upload SARIF" step is included in your workflow and uses `if: always()`.

### The differential scan analyzes all files instead of just changes

Verify that `fetch-depth: 0` is set in the `actions/checkout` step.

### The pipeline fails unexpectedly

If `strict: true` is set, the pipeline will fail whenever vulnerabilities are found. Set `strict: false` to report without failing.

## More information

- [Source code on GitHub](https://github.com/fluidattacks/sca-action)
- [Vulnerability database](https://db.fluidattacks.com)
- [Fluid Attacks documentation](https://docs.fluidattacks.com)
- [SARIF format specification](https://sarifweb.azurewebsites.net/)
