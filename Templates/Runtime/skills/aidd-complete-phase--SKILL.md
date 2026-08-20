---
name: aidd-complete-phase
description: Finalize a phase after implementation batches are complete and route to the review pipeline.
argument-hint: "[phase-number]"
disable-model-invocation: true
allowed-tools: Read Write Edit Glob Grep Bash
effort: high
---

# AIDD Complete Phase

Finalizes a phase after all implementation batches are done and routes the artifacts to the review pipeline.

## Usage

```text
/aidd-complete-phase [N]
```

## Steps

1. Locate `<TICKET>`: read the first match of `docs/*/.active_ticket` via Glob.
2. Read the Idea lane. If it is `Trivial`, do not require a phase argument or
   use phase completion:
   - verify every compact tasklist item is complete;
   - run focused checks plus one full project gate through `/aidd-run-checks`;
   - set tasklist status to `IMPLEMENT_STEP_OK`;
   - route directly to the reviewer, which produces
     `docs/<TICKET>/review/<TICKET>-review.md` from the compact review template;
   - do not create phase, QA, or security artifacts.
   Stop after reporting the Trivial review route.
3. Parse the argument as `N` (phase number). Abort if missing.
4. Read `docs/<TICKET>/phase/<TICKET>-phase-N-brief.md` and verify:
   - all execution checklist items are `[x]`
   - `Status` field exists
   - `Lane` field exists
   - `Workflow Version: 3`
5. Read `docs/<TICKET>/tasklist-<TICKET>.md` and verify:
   - phase N tasks in the Progress and Phase Breakdown sections are all `[x]`
6. Verify required phase artifacts exist:
   - `docs/<TICKET>/phase/<TICKET>-phase-N-brief.md`
   - `docs/<TICKET>/plan/<TICKET>-phase-N-plan.md`
   - `docs/<TICKET>/prd/<TICKET>-phase-N-prd.md`
   - `docs/<TICKET>/research/<TICKET>-phase-N-research.md`
7. Run the check pipeline via `/aidd-run-checks` — every stage must pass.
8. Extract `Lane` from the phase brief metadata.
9. (Enterprise / optional in Standard) Append a metrics entry to `docs/<TICKET>/metrics.log`:
   ```
   YYYY-MM-DD | phase-N | IMPLEMENT_STEP_OK | lane=<Lane>
   ```
10. Update phase brief status to `IMPLEMENT_STEP_OK`.
11. Print the review routing.

## Review routing

**Professional lane:**
1. Spawn `reviewer` agent → produces `docs/<TICKET>/review/<TICKET>-phase-N-review.md`
2. If `REVIEW_OK` → spawn `qa` agent → produces `docs/<TICKET>/qa/<TICKET>-phase-N-qa.md`
3. If `QA_FAIL` → run `/aidd-diagnose-failure N`; after diagnosis, route to an
   owner-approved fix batch or back to research/planning when an assumption
   changed

**Critical lane:**
1. Spawn `reviewer` agent → produces `docs/<TICKET>/review/<TICKET>-phase-N-review.md`
2. If `REVIEW_OK` → spawn `security-reviewer` agent → produces `docs/<TICKET>/security/<TICKET>-phase-N-security.md`
3. If `SECURITY_REVIEW_OK` → spawn `qa` agent → produces `docs/<TICKET>/qa/<TICKET>-phase-N-qa.md`
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
