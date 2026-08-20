---
name: aidd-run-checks
description: Run project quality checks (format, analyze, lint, test) with MCP-aware fallback via the project check script.
disable-model-invocation: true
allowed-tools: Bash Read
context: fork
effort: low
---

# AIDD Run Checks

Runs lane- and boundary-appropriate quality checks and stops on the first
failure.

## Usage

```text
/aidd-run-checks
```

## Steps

1. Locate the active marker and read the Idea lane plus tasklist-required checks.
2. Look for `.claude/aidd-checks.sh` (Tech Adaptor entry point).
3. For Professional/Critical, preserve the standard full pipeline below.
4. For Trivial implementation:
   - run every focused check named by the tasklist;
   - obtain one successful full project pipeline pass before `REVIEW_OK`;
   - record both focused and full evidence in the ticket review.
5. For a Trivial post-review archive transition, first prove the diff since the
   reviewed implementation contains only workspace relocation and archive/
   roadmap metadata. If true, run only:
   - repository formatting check;
   - full and quick AIDD validator;
   - `git diff --check`;
   - sensitive-content scan over the archive diff.
6. If any functional, tooling, dependency, configuration, or deployment file
   changed after review, invalidate the reduced closeout gate and rerun focused
   checks plus the full project pipeline.
7. If the configured check entry point is absent, report that the project has
   no check pipeline and suggest installing a Tech Adaptor or creating
   `.claude/aidd-checks.sh` manually.
8. Stop on the first failure and report which stage failed. If the cause is not
   self-evident, suggest `/aidd-diagnose-failure` rather than a speculative fix.

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
- A Trivial ticket reaches `IMPLEMENT_STEP_OK` only after its focused checks and
  one full pipeline pass. Reduced closeout checks never replace that pass.
- Do not rerun the full pipeline for a proven docs-only Trivial archive move;
  doing so adds latency without new functional evidence.
- MCP tools are preferred for deterministic operations; shell commands are the fallback.
- If both MCP and shell fail, report the underlying error clearly.

## Error handling

- If `.claude/aidd-checks.sh` is missing: report and suggest installing a Tech Adaptor.
- If the script is not executable: report and suggest `chmod +x .claude/aidd-checks.sh`.
- If a required tool is not on PATH: report the missing tool by name.
- If a check times out: report the timeout, do not retry automatically.
- If a failure is flaky or remains unexplained, route to
  `/aidd-diagnose-failure`; do not patch code from this skill.

## Quality gate

All stages PASS → eligible for `IMPLEMENT_STEP_OK`.
