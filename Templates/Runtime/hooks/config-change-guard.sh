#!/usr/bin/env bash

# ConfigChange hook (matcher: project_settings|skills)
# Validates settings or skill changes via the workflow validator.
# Blocks on validator failure; emits a restart hint when validation passes.

set -euo pipefail

root="${CLAUDE_PROJECT_DIR:-.}"
validator="${root}/.claude/bin/aidd_validate.sh"

if [[ ! -x "${validator}" ]]; then
  printf '%s\n' '{"continue":true,"systemMessage":"Validator missing or not executable — config change not verified."}'
  exit 0
fi

if "${validator}" >/dev/null; then
  printf '%s\n' '{"continue":true,"systemMessage":"Config changed. Restart Claude Code for hooks/skills to reload."}'
else
  echo "Validator failed after config change. Fix drift before continuing." >&2
  exit 2
fi
