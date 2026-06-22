#!/usr/bin/env bash

# PreToolUse hook (matcher: Write|Edit|MultiEdit)
# Four-tier check using the modern hookSpecificOutput JSON API:
#   1. Always deny edits to protected files (.git, .env, secrets, settings.local.json)
#   2. Edits inside source dirs require an active ticket (.active_ticket)
#   2.5 Advisory: editing source while a worked phase (tasklist status != Pending)
#       has no PRD — remind to open the phase via /aidd-new-phase. Never blocks.
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

# Is the edit inside a source dir? Disable globbing (set -f) so the configured
# patterns word-split into literal case globs (lib/*, packages/*, …) instead of
# being pathname-expanded against the cwd, which would depend on where the hook
# happens to run.
set -f
in_source=false
for pattern in ${source_dirs//|/ }; do
  case "${file_path}" in
    $pattern) in_source=true; break ;;
  esac
done
set +f

# Level 2: source dirs require an active ticket.
if [[ "${in_source}" == true ]]; then
  if ! find "${root}/docs" -maxdepth 2 -name ".active_ticket" 2>/dev/null | grep -q .; then
    deny "No active ticket. Run /aidd-new-ticket before editing source files."
  fi
fi

# Level 2.5: editing source while a worked phase lacks its PRD — advisory only.
if [[ "${in_source}" == true ]]; then
  ticket_file="$(find "${root}/docs" -maxdepth 2 -name ".active_ticket" 2>/dev/null | head -n 1 || true)"
  if [[ -n "${ticket_file}" ]]; then
    ticket="$(tr -d '[:space:]' < "${ticket_file}" 2>/dev/null || true)"
    tasklist="${root}/docs/${ticket}/tasklist-${ticket}.md"
    if [[ -n "${ticket}" && -f "${tasklist}" ]]; then
      # Progress rows: "| <N> | <goal> | <status> | ...". Flag a phase whose
      # status is neither "Pending" nor "-" but has no PRD artifact yet.
      missing=""
      while IFS=$'\t' read -r phase status; do
        [[ -z "${phase}" ]] && continue
        case "${status}" in
          ""|"-"|"Pending"|"pending") continue ;;
        esac
        if [[ ! -f "${root}/docs/${ticket}/prd/${ticket}-phase-${phase}.prd.md" ]]; then
          missing="${missing}${missing:+, }${phase}"
        fi
      done < <(
        awk -F'|' 'NF>=4 && $2 ~ /^ *[0-9]+ *$/ {
          p=$2; s=$4; gsub(/^ *| *$/,"",p); gsub(/^ *| *$/,"",s); print p"\t"s
        }' "${tasklist}" 2>/dev/null || true
      )
      if [[ -n "${missing}" ]]; then
        printf '{"hookSpecificOutput":{"permissionDecision":"allow"},"systemMessage":"AIDD reminder: %s phase(s) %s are being worked but have no PRD. Open the phase (PRD -> research -> plan) via /aidd-new-phase before implementing."}\n' "${ticket}" "${missing}"
        exit 0
      fi
    fi
  fi
fi

# Level 3: workflow-critical files — allow with advisory.
case "${file_path}" in
  CLAUDE.md|AGENTS.md|docs/README.md|docs/project/workflow.md|docs/project/templates/*|.claude/*)
    printf '{"hookSpecificOutput":{"permissionDecision":"allow"},"systemMessage":"Workflow file: %s. Validator will re-check on save."}\n' "${file_path}"
    exit 0
    ;;
esac

printf '{"hookSpecificOutput":{"permissionDecision":"allow"}}\n'
