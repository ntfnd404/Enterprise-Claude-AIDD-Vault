#!/usr/bin/env bash

# InstructionsLoaded hook — async advisory.
# Reminds Claude of active workflow discipline at session start.
# Runs async: does not block, does not inject context tokens — UI signal only.

set -euo pipefail

printf '%s\n' '{"continue":true,"systemMessage":"AIDD v3 active. Default lane: Professional. Critical lane mandatory for high-risk domains (see CLAUDE.md)."}'
