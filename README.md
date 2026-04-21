# Fluid Attacks SCA

Free, open-source software composition analysis (SCA) action for your GitHub repositories. No account, API key, or registration required.

Scans your project dependencies for known vulnerabilities automatically on every push and pull request.

## Quick Start (2 minutes)

### 1. Create the GitHub Actions workflow

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

      - uses: fluidattacks/sca-action@<version>
        id: scan
```

Replace `<version>` with the latest release tag. Check the releases page for the current version and update whenever a new one is published.

Without a configuration file, the action scans the entire repository and writes results to `.fluidattacks-sca-results.sarif`.

### 2. (Optional) Add a configuration file

To customize scan paths, output format, or strict mode, create a YAML file anywhere in your repository and pass its path to the action:

```yaml
- uses: fluidattacks/sca-action@<version>
  id: scan
  with:
    scan_config_path: .github/sca-config.yaml
```

See [Configuration reference](#configuration-reference) for the full list of options.

Commit and push. The scan will run automatically on the next push or pull request.

## How it works

### Scan modes

By default, the action always performs a **full scan** — it analyzes all dependencies in the repository on every run, regardless of the event or branch.

You can switch to a differential scan with `scanner_mode: diff` — see [Action inputs](#action-inputs).

### Why `fetch-depth: 0` is not needed by default

Full scan mode skips all git comparisons, so the default shallow checkout is sufficient. You only need `fetch-depth: 0` if you set `scanner_mode: diff`.

## Viewing results

After the workflow runs, results are written to the path configured in `output.file_path` (e.g. `results.sarif`), or to `.fluidattacks-sca-results.sarif` when no configuration file is provided.

### SARIF file

The raw SARIF file is always available in your workspace. You can download it as an artifact, process it with other tools, or upload it to a third-party platform.

### GitHub Security tab (optional)

You can upload the SARIF file to GitHub's Security tab so findings appear as **Code scanning alerts** with inline PR annotations:

```yaml
- name: Upload results to GitHub Security tab
  if: always()
  uses: github/codeql-action/upload-sarif@v4
  with:
    sarif_file: ${{ steps.scan.outputs.sarif_file }}
```

> **Restrictions:** SARIF upload to the Security tab requires **GitHub Advanced Security**, which is available on all public repositories and on private repositories under a GitHub Advanced Security license. On private repositories without that license, the upload step will fail. See [GitHub's documentation](https://docs.github.com/en/code-security/code-scanning/integrating-with-code-scanning/uploading-a-sarif-file-to-github) for details.

## Configuration reference

When `scan_config_path` is provided, the action uses that file exclusively. When omitted, the action runs with built-in defaults: scans the entire repository (`sca.include: [.]`) and writes results to `.fluidattacks-sca-results.sarif`.

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
| `scan_config_path` | No | — | Path to the YAML configuration file, relative to the repository root. When omitted, the action runs with built-in defaults. The job fails if the file does not exist at the given path. |
| `scanner_mode` | No | `full` | Scan mode. `full` scans the entire repository (default). `diff` scans only changed files versus the base branch or PR base. |

### `scan_config_path`

Point the action at your configuration file:

```yaml
- uses: fluidattacks/sca-action@<version>
  id: scan
  with:
    scan_config_path: .github/sca-config.yaml
```

The path is relative to the repository root. The job fails immediately if the file does not exist.

### `scanner_mode: diff`

Scans only the files changed relative to the base branch (on pushes) or the PR base (on pull requests). Requires `fetch-depth: 0` in the checkout step so the action can compare git history.

Diff mode is only active on `push` and `pull_request` events. For any other event (e.g. `schedule`, `workflow_dispatch`), the action automatically falls back to a full scan.

```yaml
- uses: actions/checkout@v4
  with:
    fetch-depth: 0

- uses: fluidattacks/sca-action@<version>
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

If `strict: true` is set in your configuration file, the pipeline will fail whenever vulnerabilities are found. Set `strict: false` to report without failing.

### The job fails with "not found in repository"

The path provided to `scan_config_path` does not exist in the repository. Verify the path is correct and relative to the repository root.

## More information

- [Source code on GitHub](https://github.com/fluidattacks/sca-action)
- [Vulnerability database](https://db.fluidattacks.com)
- [Fluid Attacks documentation](https://docs.fluidattacks.com)
- [SARIF format specification](https://sarifweb.azurewebsites.net/)
