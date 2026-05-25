---
name: aidd-run-checks
description: Run project quality checks (format, analyze, lint, test) with MCP-aware fallback via the project check script.
disable-model-invocation: true
allowed-tools: Bash Read
context: fork
effort: low
---

# AIDD Run Checks

Runs the standard quality checks in sequence and stops on the first failure.

## Usage

```text
/aidd-run-checks
```

## Steps

1. Look for `.claude/aidd-checks.sh` (Tech Adaptor entry point).
2. If present: execute it and parse the output for per-stage results.
3. If absent: report that the project has no check pipeline and suggest installing a Tech Adaptor or creating `.claude/aidd-checks.sh` manually.
4. Stop on the first failure and report which stage failed.

## Expected pipeline

The check script must run these stages in order, stopping on the first failure:

| Stage | Purpose |
|-------|---------|
| format  | Format only changed source files (cheap, fast) |
| analyze | Static analysis with zero tolerance for warnings or infos |
| lint    | Stack-specific style/quality rules |
| test    | Full test suite |

Each stage should prefer MCP tools (deterministic, hermetic) and fall back to shell commands when MCP is unavailable.

## Output format

```text
## Quality checks

format:  PASS | FAIL
analyze: PASS | FAIL
lint:    PASS | FAIL
tests:   PASS | FAIL

Overall: PASS | FAIL
```

## Rules

- Stop on the first failure and report which check failed.
- Do not silently auto-fix code beyond the configured formatter.
- Do not suppress warnings — analyze treats warnings/infos as failures.
- All four stages must pass before a phase can advance to `IMPLEMENT_STEP_OK`.
- MCP tools are preferred for deterministic operations; shell commands are the fallback.
- If both MCP and shell fail, report the underlying error clearly.

## Error handling

- If `.claude/aidd-checks.sh` is missing: report and suggest installing a Tech Adaptor.
- If the script is not executable: report and suggest `chmod +x .claude/aidd-checks.sh`.
- If a required tool is not on PATH: report the missing tool by name.
- If a check times out: report the timeout, do not retry automatically.

## Quality gate

All stages PASS → eligible for `IMPLEMENT_STEP_OK`.
