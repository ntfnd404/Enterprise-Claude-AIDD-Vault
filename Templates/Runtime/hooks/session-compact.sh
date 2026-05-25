#!/usr/bin/env bash

# SessionStart hook (matcher: compact)
# Recovers context after compaction. Looks up the active ticket and reminds
# Claude to re-read phase brief, plan, PRD, and conventions before editing.

set -euo pipefail
root="${CLAUDE_PROJECT_DIR:-.}"

ticket_file=""
if [[ -d "${root}/docs" ]]; then
  ticket_file="$(find "${root}/docs" -maxdepth 2 -name ".active_ticket" 2>/dev/null | head -1 || true)"
fi

if [[ -z "${ticket_file}" ]]; then
  printf '%s\n' '{"continue":true,"systemMessage":"Session resumed. No active ticket — start with /aidd-new-ticket."}'
  exit 0
fi

ticket="$(cat "${ticket_file}" | tr -d '[:space:]')"
msg="Session resumed. Active ticket: ${ticket}. Re-read phase brief, plan, PRD, and conventions before editing."
msg="${msg//\"/\\\"}"
printf '{"continue":true,"systemMessage":"%s"}\n' "${msg}"
