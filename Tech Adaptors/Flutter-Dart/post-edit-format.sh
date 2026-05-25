#!/usr/bin/env bash
# PostToolUse hook for Flutter-Dart
# Auto-formats .dart files after Write|Edit|MultiEdit

set -euo pipefail

input_json="$(cat)"
file_path=$(echo "$input_json" | jq -r '.tool_input.file_path // .tool_input.file // empty' 2>/dev/null || true)

if [[ -z "$file_path" ]]; then
  exit 0
fi

# Only format .dart files
case "$file_path" in
  *.dart)
    if [[ -f "$file_path" ]]; then
      dart format --fix "$file_path" >/dev/null 2>&1 || true
    fi
    ;;
esac

exit 0
