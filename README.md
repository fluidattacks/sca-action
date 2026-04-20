# Fluid Attacks SCA

Free, open-source software composition analysis (SCA) action for your GitHub repositories. No account, API key, or registration required.

Scans your project dependencies for known vulnerabilities automatically on every push and pull request.

## Quick Start (2 minutes)

### 1. Create the configuration file

Add a file called `.fluidattacks.yaml` in the root of your repository:

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

      - uses: fluidattacks/sca-action@1.0.0
        id: scan
```

Commit both files, push, and the scan will run automatically.

## How it works

### Scan modes

By default, the action always performs a **full scan** — it analyzes all dependencies in the repository on every run, regardless of the event or branch.

You can switch to a differential scan with `scanner_mode: diff` — see [Action inputs](#action-inputs).

### Why `fetch-depth: 0` is not needed by default

Full scan mode skips all git comparisons, so the default shallow checkout is sufficient. You only need `fetch-depth: 0` if you set `scanner_mode: diff`.

## Configuration reference

The action looks for configuration in the following order:

1. **`.fluidattacks.yaml`** — primary config file (recommended)
2. **`.sca.yaml`** — legacy config file, used if `.fluidattacks.yaml` is not present
3. **Built-in defaults** — if neither file exists, the action scans the entire repository (`sca.include: [.]`) and writes results to `.fluidattacks-sca-results.sarif`

Place whichever file you use at the root of your repository.

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
| `output.file_path` | No | `.fluidattacks-sca-results.sarif` | Path for the output file |
| `output.format` | No | `SARIF` | Output format: `SARIF`, `CSV`, or `ALL` |
| `sca.include` | No | `[.]` | List of paths to scan |
| `sca.exclude` | No | — | List of paths to exclude |

## Action inputs

| Input | Required | Default | Description |
|---|---|---|---|
| `scanner_mode` | No | `full` | Scan mode. `full` scans the entire repository (default). `diff` scans only changed files versus the base branch or PR base. |

### `scanner_mode: diff`

Scans only the files changed relative to the base branch (on pushes) or the PR base (on pull requests). Requires `fetch-depth: 0` in the checkout step so the action can compare git history.

Diff mode is only active on `push` and `pull_request` events. For any other event (e.g. `schedule`, `workflow_dispatch`), the action automatically falls back to a full scan.

```yaml
- uses: actions/checkout@v4
  with:
    fetch-depth: 0

- uses: fluidattacks/sca-action@1.0.0
  id: scan
  with:
    scanner_mode: diff
```

## Action outputs

| Output | Description |
|---|---|
| `sarif_file` | Path to the SARIF results file (when format is `SARIF` or `ALL`) |
| `vulnerabilities_found` | `true` if any vulnerabilities were detected, `false` otherwise |

## Troubleshooting

### The scan runs but no results appear in the Security tab

Make sure the "Upload SARIF" step is included in your workflow and uses `if: always()`.

### The differential scan analyzes all files instead of just changes

Verify that `fetch-depth: 0` is set in the `actions/checkout` step and that `scanner_mode: diff` is configured.

### The pipeline fails unexpectedly

If `strict: true` is set, the pipeline will fail whenever vulnerabilities are found. Set `strict: false` to report without failing.

## More information

- [Source code on GitHub](https://github.com/fluidattacks/sca-action)
- [Vulnerability database](https://db.fluidattacks.com)
- [Fluid Attacks documentation](https://docs.fluidattacks.com)
- [SARIF format specification](https://sarifweb.azurewebsites.net/)
