#!/usr/bin/env bash

# PreToolUse hook (matcher: Write|Edit|MultiEdit)
# Three-tier check using the modern hookSpecificOutput JSON API:
#   1. Always deny edits to protected files (.git, .env, secrets, settings.local.json)
#   2. Edits inside source dirs require an active ticket (.active_ticket)
#   3. Workflow-critical files are allowed with an advisory systemMessage
#
# Source dirs are configurable via $AIDD_SOURCE_DIRS (pipe-separated globs).

set -euo pipefail

input_json="$(cat)"
file_path="$(
  printf '%s' "${input_json}" |
    grep -oE '"file_path"\s*:\s*"[^"]+"' |
    head -n 1 |
    sed -E 's/^"file_path"\s*:\s*"//; s/"$//'
)"

if [[ -z "${file_path}" ]]; then
  printf '{"continue":true}\n'
  exit 0
fi

root="${CLAUDE_PROJECT_DIR:-.}"
source_dirs="${AIDD_SOURCE_DIRS:-lib/*|src/*|packages/*|app/*}"

deny() {
  local reason="$1"
  reason="${reason//\\/\\\\}"
  reason="${reason//\"/\\\"}"
  printf '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"%s"}\n' "${reason}"
  exit 0
}

# Level 1: protected files — always deny.
case "${file_path}" in
  .git/*|.env|.env.*|*/secrets/*|.claude/settings.local.json)
    deny "Blocked: ${file_path} is a protected file."
    ;;
esac

# Level 2: source dirs require an active ticket.
for pattern in ${source_dirs//|/ }; do
  case "${file_path}" in
    $pattern)
      if ! find "${root}/docs" -maxdepth 2 -name ".active_ticket" 2>/dev/null | grep -q .; then
        deny "No active ticket. Run /aidd-new-ticket before editing source files."
      fi
      ;;
  esac
done

# Level 3: workflow-critical files — allow with advisory.
case "${file_path}" in
  CLAUDE.md|AGENTS.md|docs/README.md|docs/project/workflow.md|docs/project/templates/*|.claude/*)
    printf '{"hookSpecificOutput":{"permissionDecision":"allow"},"systemMessage":"Workflow file: %s. Validator will re-check on save."}\n' "${file_path}"
    exit 0
    ;;
esac

printf '{"hookSpecificOutput":{"permissionDecision":"allow"}}\n'
