#!/usr/bin/env bash

# TaskCreated / TaskCompleted / TeammateIdle hook — async advisory.
# Team mode orchestration signals. Suppressed unless AIDD_TEAM_MODE=1.

set -euo pipefail

mode="${1:-event}"
team_mode="${AIDD_TEAM_MODE:-0}"

if [[ "${team_mode}" != "1" ]]; then
  printf '{"continue":true,"suppressOutput":true}\n'
  exit 0
fi

case "${mode}" in
  created)
    message="Team task created. Keep the orchestrator in the lead session; split only disjoint workstreams."
    ;;
  completed)
    message="Team task completed. Integrate results explicitly; do not skip reviewer or QA gates."
    ;;
  idle)
    message="Teammate idle. Rebalance only when a clear independent workstream exists; do not create busywork."
    ;;
  *)
    message="Team lifecycle event observed."
    ;;
esac

printf '{"continue":true,"systemMessage":"%s"}\n' "${message}"
