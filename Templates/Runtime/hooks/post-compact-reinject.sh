#!/usr/bin/env bash

# PostCompact hook
# Reinjects ticket / phase / lane / goal into context after compaction.
# Prefers the latest non-STUB phase brief; falls back to the latest brief
# (any status) and finally to the first heading if a `Goal:` header is missing.

set -euo pipefail
cat >/dev/null

root="${CLAUDE_PROJECT_DIR:-.}"

ticket_file=""
if [[ -d "${root}/docs" ]]; then
  ticket_file="$(find "${root}/docs" -maxdepth 2 -name ".active_ticket" 2>/dev/null | head -1 || true)"
fi

if [[ -z "${ticket_file}" ]]; then
  printf '{"continue":true,"systemMessage":"No active ticket. Start with /aidd-new-ticket."}\n'
  exit 0
fi

ticket="$(cat "${ticket_file}" | tr -d '[:space:]')"
ticket_dir="$(dirname "${ticket_file}")"

# Find the most recent non-STUB phase brief; otherwise fall back to the
# latest brief regardless of status.
latest_phase=""
phase_dir="${ticket_dir}/phase/${ticket}"
if [[ -d "${phase_dir}" ]]; then
  for f in $(ls "${phase_dir}" 2>/dev/null | sort -Vr); do
    if ! grep -q 'Status:.*STUB' "${phase_dir}/${f}" 2>/dev/null; then
      latest_phase="${f}"
      break
    fi
  done
  if [[ -z "${latest_phase}" ]]; then
    latest_phase="$(ls "${phase_dir}" 2>/dev/null | sort -V | tail -1 || true)"
  fi
fi

lane="unknown"
goal="unknown"
if [[ -n "${latest_phase}" ]]; then
  brief="${phase_dir}/${latest_phase}"
  lane="$(grep -m1 "^Lane:" "${brief}" 2>/dev/null | sed 's/^Lane: *//' || echo "unknown")"
  goal="$(grep -m1 "^Goal:" "${brief}" 2>/dev/null | sed 's/^Goal: *//' || echo "unknown")"
  if [[ "${goal}" == "unknown" ]]; then
    goal="$(head -1 "${brief}" 2>/dev/null | sed 's/^# Phase [0-9]*: //' || echo "unknown")"
  fi
fi

phase_id="${latest_phase%.md}"
msg="Context restored. Ticket: ${ticket} | Phase: ${phase_id} | Lane: ${lane} | Goal: ${goal}. Re-read phase brief and plan before continuing."
msg="${msg//\"/\\\"}"
printf '{"continue":true,"systemMessage":"%s"}\n' "${msg}"
