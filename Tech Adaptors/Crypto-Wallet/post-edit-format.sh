#!/usr/bin/env bash
# PostToolUse hook for Crypto-Wallet (domain adaptor)
#
# This is a domain adaptor, not a tech-stack adaptor — formatting is owned by the
# stack adaptor (e.g., Flutter-Dart, Kotlin-Android). This script is a no-op
# placeholder so the adaptor structure matches the vault template (5 files).
#
# Do NOT register this hook in settings.json. The stack adaptor's
# post-edit-format.sh handles formatting for all source files.

set -euo pipefail

# Drain stdin so the caller does not block on a closed pipe.
cat >/dev/null 2>&1 || true

exit 0
