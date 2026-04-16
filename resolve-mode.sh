#!/usr/bin/env bash
set -euo pipefail

out() { echo "$1" >> "${GITHUB_OUTPUT}"; }

if [[ ! -f ".sca.yaml" ]]; then
  echo "::error::Config file .sca.yaml not found in repository root."
  exit 1
fi

# Diff mode is only valid on push and pull_request events
if [[ "${SCANNER_MODE}" == "diff" ]]; then
  if [[ "${GITHUB_EVENT_NAME}" == "pull_request" ]]; then
    out "mode=diff"
    out "base_sha=${PR_BASE_SHA}"
    exit 0
  elif [[ "${GITHUB_EVENT_NAME}" == "push" ]]; then
    DEFAULT_BRANCH=$(git remote show origin | grep 'HEAD branch' | awk '{print $NF}')
    out "mode=diff"
    out "base_sha=origin/${DEFAULT_BRANCH}"
    exit 0
  fi
  # Other events (schedule, workflow_dispatch, etc.) fall through to full scan
fi

# Default: full scan
out "mode=full"
