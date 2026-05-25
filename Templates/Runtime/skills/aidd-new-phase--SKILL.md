---
name: aidd-new-phase
description: Scaffold phase artifacts (PRD, research, plan, brief) for a new phase.
argument-hint: "phase-number"
disable-model-invocation: true
allowed-tools: Read Write Glob Grep Bash
---

# AIDD New Phase

Creates the phase artifacts for one phase of the active feature ticket.

## Usage

```text
/aidd-new-phase N
```

## Steps

1. Parse argument as `N` (phase number). Abort if missing.
2. Locate `<TICKET>`: read the first match of `docs/*/.active_ticket` via Glob.
3. Read `docs/<TICKET>/idea-<TICKET>.md` to extract:
   - `Lane` (Professional or Critical; falls back to Professional with a warning)
   - `Ticket` ID for verification
4. Verify the phase artifacts do not already exist. Abort if any file in the set exists.
5. Read templates:
   - `docs/project/templates/phase_brief.md`
   - `docs/project/templates/phase_plan.md`
   - `docs/project/templates/phase_prd.md`
   - `docs/project/templates/phase_research.md`
6. Create `docs/<TICKET>/phase/<TICKET>/phase-N.md` from `phase_brief.md` with substitutions:

   | Field | Value |
   |-------|-------|
   | `<TICKET-ID>` | `<TICKET>` |
   | `Phase: N` | phase number from argument |
   | `Lane` | from idea |
   | `Workflow Version` | `3` |
   | `Owner` | `Implementer` |
   | `Status` | template default |

7. Create `docs/<TICKET>/plan/<TICKET>-phase-N.md` from `phase_plan.md` with the same metadata substitutions. Owner: `Planner / Architect`.
8. Create `docs/<TICKET>/prd/<TICKET>-phase-N.prd.md` from `phase_prd.md` with the same metadata substitutions. Owner: `Analyst`.
9. Create `docs/<TICKET>/research/<TICKET>-phase-N.md` from `phase_research.md` with the same metadata substitutions. Owner: `Researcher`.
10. Ensure directories exist: `docs/<TICKET>/security/`, `docs/<TICKET>/qa/`.
11. Update `docs/<TICKET>/tasklist-<TICKET>.md`:
    - add a row to the Progress table for phase N
    - add a Phase N section to the Phase Breakdown
12. Report created artifacts and routing: analyst → researcher → planner.

## Rules

- Keep all template metadata fields intact after substitution.
- Do not create security review or QA files at scaffold time; their respective agents produce them.
- If the lane is `Trivial`, do not use this skill — Trivial work skips phase scaffolding.
- If the lane is `Critical`, note in the output that a security review will be required after the reviewer gate.

## Error handling

- If `.active_ticket` not found: ask the user to run `/aidd-new-ticket` first.
- If phase artifacts already exist: report and abort.
- If lane is missing from the idea: warn and default to `Professional`.

## Quality gate

Artifacts are ready for the analyst → researcher → planner pipeline.
