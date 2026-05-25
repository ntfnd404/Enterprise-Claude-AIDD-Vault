#!/usr/bin/env bash

# FileChanged hook (matcher: workflow-critical paths)
# Re-runs the workflow validator when shared docs, runtime files, or
# templates change. Blocks on validator failure to surface drift early.

set -euo pipefail

root="${CLAUDE_PROJECT_DIR:-.}"
validator="${root}/.claude/bin/aidd_validate.sh"

if [[ ! -x "${validator}" ]]; then
  printf '%s\n' '{"continue":true,"systemMessage":"Validator missing or not executable — workflow file change not verified."}'
  exit 0
fi

if "${validator}" >/dev/null; then
  printf '%s\n' '{"continue":true}'
else
  echo "Validator failed after workflow file change. Fix drift before continuing." >&2
  exit 2
fi
