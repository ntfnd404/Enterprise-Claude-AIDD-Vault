---
name: aidd-complete-phase
description: Finalize a phase after implementation batches are complete and route to the review pipeline.
argument-hint: "phase-number"
disable-model-invocation: true
allowed-tools: Read Write Edit Glob Grep Bash
effort: high
---

# AIDD Complete Phase

Finalizes a phase after all implementation batches are done and routes the artifacts to the review pipeline.

## Usage

```text
/aidd-complete-phase N
```

## Steps

1. Parse argument as `N` (phase number). Abort if missing.
2. Locate `<TICKET>`: read the first match of `docs/*/.active_ticket` via Glob.
3. Read `docs/<TICKET>/phase/<TICKET>/phase-N.md` and verify:
   - all execution checklist items are `[x]`
   - `Status` field exists
   - `Lane` field exists
   - `Workflow Version: 3`
4. Read `docs/<TICKET>/tasklist-<TICKET>.md` and verify:
   - phase N tasks in the Progress and Phase Breakdown sections are all `[x]`
5. Verify required phase artifacts exist:
   - `docs/<TICKET>/phase/<TICKET>/phase-N.md`
   - `docs/<TICKET>/plan/<TICKET>-phase-N.md`
   - `docs/<TICKET>/prd/<TICKET>-phase-N.prd.md`
   - `docs/<TICKET>/research/<TICKET>-phase-N.md`
6. Run the check pipeline via `/aidd-run-checks` — every stage must pass.
7. Extract `Lane` from the phase brief metadata.
8. (Enterprise / optional in Standard) Append a metrics entry to `docs/<TICKET>/metrics.log`:
   ```
   YYYY-MM-DD | phase-N | IMPLEMENT_STEP_OK | lane=<Lane>
   ```
9. Update phase brief status to `IMPLEMENT_STEP_OK`.
10. Print the review routing.

## Review routing

**Professional lane:**
1. Spawn `reviewer` agent → produces `docs/<TICKET>/<TICKET>-phase-N-summary.md`
2. If `REVIEW_OK` → spawn `qa` agent → produces `docs/<TICKET>/qa/<TICKET>-phase-N.md`
3. If `QA_FAIL` → report issues, return to implementation

**Critical lane:**
1. Spawn `reviewer` agent → produces `docs/<TICKET>/<TICKET>-phase-N-summary.md`
2. If `REVIEW_OK` → spawn `security-reviewer` agent → produces `docs/<TICKET>/security/<TICKET>-phase-N.md`
3. If `SECURITY_REVIEW_OK` → spawn `qa` agent → produces `docs/<TICKET>/qa/<TICKET>-phase-N.md`
4. If `SECURITY_REVIEW_BLOCKED` → report, do not proceed to QA

## Output format

```text
## Phase N completion check

tasks:     PASS | FAIL (X/Y checked)
artifacts: PASS | FAIL
checks:    PASS | FAIL
lane:      Professional | Critical

Status: IMPLEMENT_STEP_OK

Next steps:
1. reviewer
2. security-reviewer (Critical only)
3. qa
```

## Error handling

- If unchecked tasks remain: list them and abort.
- If checks fail: report which check failed, abort.
- If a required artifact is missing: list missing files and abort.
- Do not advance gate status if any verification fails.

## Quality gate

`TASKLIST_READY` → `IMPLEMENT_STEP_OK` (this skill)
→ `REVIEW_OK` → (`SECURITY_REVIEW_OK`) → `QA_PASS`
