# Flutter-Dart Run Checks Overlay

This defines the check pipeline for `.claude/aidd-checks.sh`.

## Pipeline

### 1. Format (changed files only)

```bash
# Get changed .dart files
changed=$(git diff --name-only --diff-filter=d HEAD 2>/dev/null | grep '\.dart$' || true)

if [[ -z "$changed" ]]; then
  echo "FORMAT: PASS (no changed .dart files)"
else
  # MCP-first
  # Try: mcp__dart__dart_format with paths parameter
  # Fallback:
  echo "$changed" | xargs dart format --set-exit-if-changed
fi
```

### 2. Analyze (zero tolerance)

```bash
# MCP-first
# Try: mcp__dart__analyze_files
# Fallback:
flutter analyze --fatal-infos --fatal-warnings
```

### 3. DCM (if configured)

```bash
# DCM is a separate CLI tool — Dart MCP analyze_files does NOT run DCM rules
if command -v dcm &>/dev/null; then
  dcm analyze lib/ packages/ test/ tool/ --fatal-style --fatal-warnings
else
  echo "FAIL: dcm is required but not installed" >&2
  exit 1
fi
```

### 4. Test

```bash
# MCP-first
# Try: mcp__dart__run_tests
# Fallback:
flutter test
```

## Generated `aidd-checks.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "=== AIDD Checks: Flutter-Dart ==="

# 1. Format
echo "--- Format ---"
changed=$(git diff --name-only --diff-filter=d HEAD 2>/dev/null | grep '\.dart$' || true)
if [[ -z "$changed" ]]; then
  echo "PASS (no changed .dart files)"
else
  echo "$changed" | xargs dart format --set-exit-if-changed
  echo "PASS"
fi

# 2. Analyze
echo "--- Analyze ---"
flutter analyze --fatal-infos --fatal-warnings
echo "PASS"

# 3. DCM
if command -v dcm &>/dev/null; then
  echo "--- DCM ---"
  dcm analyze lib/ packages/ test/ tool/ --fatal-style --fatal-warnings
  echo "PASS"
else
  echo "FAIL: dcm is required but not installed" >&2
  exit 1
fi

# 4. Test
echo "--- Test ---"
flutter test
echo "PASS"

echo "=== All checks passed ==="
```
