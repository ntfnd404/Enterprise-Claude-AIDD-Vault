#!/usr/bin/env bash

# SubagentStart / SubagentStop hook — async advisory.
# Reminds Claude of delegation discipline and the gate routing model.
# Runs async: does not block, does not inject critical context.

set -euo pipefail

mode="${1:-event}"
cat >/dev/null

case "${mode}" in
  start)
    message="Subagent started. Keep critical-path reasoning in the main session; delegate only disjoint workstreams."
    ;;
  stop)
    message="Subagent done. Apply gates: reviewer → security-reviewer (Critical only) → qa. Do not skip gates."
    ;;
  *)
    message="Subagent lifecycle event observed."
    ;;
esac

printf '{"continue":true,"systemMessage":"%s"}\n' "${message}"
