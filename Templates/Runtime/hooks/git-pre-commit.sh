#!/usr/bin/env bash

# Git pre-commit hook that runs the AIDD workflow validator.
#
# This is an OPTIONAL local-only enforcement layer — it is NOT part of the
# Claude Code hook system in .claude/settings.json. It exists to catch
# workflow drift before code reaches the remote.
#
# Install (per-project):
#   cp .claude/hooks/git-pre-commit.sh .git/hooks/pre-commit
#   chmod +x .git/hooks/pre-commit
#
# Or wire it into the project Makefile / installer of choice.

set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"

if [[ ! -x "${ROOT_DIR}/.claude/bin/aidd_validate.sh" ]]; then
  echo "AIDD validator not found or not executable. Skipping."
  exit 0
fi

echo "Running AIDD workflow validator..."

if ! "${ROOT_DIR}/.claude/bin/aidd_validate.sh"; then
  echo
  echo "AIDD validation failed. Fix the issues above before committing."
  echo "Run '/aidd-validate' in Claude Code for details."
  exit 1
fi
