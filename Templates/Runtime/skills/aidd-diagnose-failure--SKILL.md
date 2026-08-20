---
name: aidd-diagnose-failure
description: Diagnose an AIDD QA_FAIL, flaky test, runtime bug, or unexplained check failure before proposing a fix. Do not use for an expected TDD red test or an obvious local syntax error.
argument-hint: "[phase-number] [failure-summary]"
disable-model-invocation: true
allowed-tools: Read Glob Grep Bash
effort: high
---

# AIDD Diagnose Failure

Establishes a reproducible, evidence-backed root cause before implementation
resumes. This skill is read-only: it may inspect files and run non-mutating
diagnostic commands, but it never edits source, artifacts, configuration, or
gate status.

## Usage

```text
/aidd-diagnose-failure [phase-number] [failure-summary]
```

Codex users invoke the same workflow explicitly as
`$aidd-diagnose-failure`.

## Inputs

1. Locate the first `docs/*/.active_ticket` marker and resolve `<TICKET>`.
   Abort with a route to `/aidd-new-ticket` if no active ticket exists.
2. Read the Idea lane and tasklist. For Professional/Critical, require the
   phase number and read the current phase brief, plan, PRD, and latest QA
   report when present. For Trivial, use the compact tasklist and review.
3. Read the failure summary from the remaining arguments. If it is incomplete,
   derive the exact symptom from the referenced QA report or check output; if
   neither exists, report the missing evidence and stop.
4. Record `git status --short` before running diagnostics so pre-existing
   changes are not mistaken for changes made by this workflow.

## Diagnostic Protocol

1. **Define the failure.** State expected behavior, actual behavior, relevant
   environment, and the smallest known command or user sequence.
2. **Reproduce narrowly.** Run the smallest non-mutating check that can expose
   the failure. Avoid repeatedly running the full project pipeline when a
   focused test or scenario is available. For a flaky failure, report the
   number of repetitions and the observed pass/fail distribution.
3. **Locate the first broken boundary.** Trace inputs and state through the
   relevant layers. Prefer the earliest point where observed behavior diverges
   from the contract, not the last line in the stack trace.
4. **Test hypotheses one at a time.** For each plausible cause, name the
   prediction and run one controlled observation that can support or reject it.
   Do not patch code as an experiment and do not treat correlation as proof.
5. **Conclude or stop.** Mark the root cause `CONFIRMED` only when reproduction
   plus a controlled observation explains the failure. Otherwise return the
   exact literal `ROOT_CAUSE_UNCONFIRMED` and do not propose implementation as
   ready to start.
6. **Design regression evidence.** Identify the test or scenario that must fail
   before the fix and pass after it, plus the focused and full verification
   commands required by the project.
7. Record `git status --short` again and report any tracked-file difference.
   Any difference introduced by diagnostics is a contract violation and must
   be reported without advancing work.

## Routing

- Confirmed cause within the approved specification: propose one minimal fix
  batch and wait for owner approval before implementation.
- Changed product, platform, or architecture assumption: stop and route to the
  appropriate researcher/planner update and specification amendment before any
  affected code change.
- Environment or toolchain blocker: report the missing capability and the exact
  unblock condition; do not relabel it as an application defect.
- `ROOT_CAUSE_UNCONFIRMED`: report the remaining hypotheses and missing
  evidence; do not guess a fix.
- Expected TDD red test or obvious syntax error introduced in the current
  approved batch: report that this workflow is not required and return to that
  batch without creating a new diagnostic cycle.

Stack-specific skills such as `dart-fix-runtime-errors`,
`flutter-fix-layout-issues`, and `dart-add-unit-test` may be proposed for the
subsequent owner-approved implementation batch. They do not replace this
diagnosis and are not invoked here when they edit code.

## Output Format

```text
## Failure diagnosis

ticket: <TICKET>
phase: <N | trivial>
lane: <Trivial | Professional | Critical>

### Failure contract
expected: <behavior>
actual: <behavior>
environment: <relevant facts>

### Reproduction
command/scenario: <exact steps>
result: <deterministic | flaky distribution | not reproduced>

### Evidence
- <observation with file/command reference>

### Hypotheses
| Hypothesis | Prediction | Observation | Result |
|---|---|---|---|

### Root cause
CONFIRMED: <causal explanation>
or
ROOT_CAUSE_UNCONFIRMED

### Regression proof
- failing-before-fix: <test/scenario>
- focused verification: <command>
- full gate: /aidd-run-checks

### Routing
<owner-approved fix batch | research/planning amendment | blocker | stop>

tracked-file integrity: PASS | VIOLATION
```

## Rules

- Do not edit files, apply fixes, format sources, update artifacts, or advance a
  gate.
- Preserve existing working-tree changes and never clean or reset them.
- Do not expose secrets or copy raw sensitive runtime data into the report.
- QA evidence describes the symptom; an unverified QA explanation is a
  hypothesis, not a root cause.
- Ordinary reviewer findings remain in the review loop unless they expose a
  runtime, flaky, or otherwise unexplained behavioral failure.

## Quality Gate

This skill creates no gate. It returns either an evidence-backed proposal for a
new owner-approved batch or a blocking diagnostic result.
