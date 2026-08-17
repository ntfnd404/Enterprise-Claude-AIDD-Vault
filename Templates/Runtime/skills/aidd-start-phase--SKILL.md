---
name: aidd-start-phase
description: Load current phase context and propose the next implementation batch.
argument-hint: "[phase-number]"
disable-model-invocation: true
allowed-tools: Read Glob Grep
effort: medium
---

# AIDD Start Phase

Loads the current phase execution packet before implementation begins.

## Usage

```text
/aidd-start-phase [N]
```

## Steps

1. Locate `<TICKET>`: read the first match of `docs/*/.active_ticket` via Glob.
2. Read the Idea lane. If it is `Trivial`, do not require a phase argument or
   look for phase artifacts:
   read the compact tasklist, propose its next bounded batch using the Fast Path,
   and wait for owner approval. Otherwise continue below.
3. Parse the argument as `N` (phase number). Abort if missing.
4. Verify the phase brief status is `TASKLIST_READY` or higher. Abort if it is still a stub.
5. Read in order:
   - `docs/<TICKET>/phase/<TICKET>-phase-N-brief.md` — execution packet
   - `docs/<TICKET>/plan/<TICKET>-phase-N-plan.md` — implementation design
   - `docs/<TICKET>/prd/<TICKET>-phase-N-prd.md` — acceptance criteria
   - `docs/project/conventions.md` — architecture rules
   - `docs/project/code-style-guide.md` — style rules
6. Extract from phase brief:
   - `Lane`
   - `Goal`
   - execution checklist items (find first unchecked `- [ ]`)
   - stop conditions
   - acceptance criteria
7. Extract from plan:
   - file changes table
   - sequencing
   - risks
8. Output a concise execution summary in this format:

```text
## Phase N: <goal>

Lane: Professional | Critical
Goal: <one line from phase brief>

## Current batch
- <first unchecked task>
- <next related unchecked tasks forming one logical unit>

## Key constraints
- <from conventions or plan>

## Risks
- <from plan>

## Proposal
I propose to implement [batch description]. This covers tasks N.X through N.Y.
Waiting for your approval before starting.
```

## Rules

- Read-only skill — do not modify any files.
- If all tasks are checked: report that the phase is complete and suggest `/aidd-complete-phase N`.
- If plan and brief conflict on scope: note the conflict and ask for resolution.
- `Critical` batch must be smaller than a `Professional` batch.
- For Trivial, use no phase number, state which standard steps are skipped and
  retained, and apply the eligibility/reclassification rules in the workflow.
- Always end with an explicit proposal and wait for approval.

## Error handling

- If phase brief not found: suggest `/aidd-new-phase N`.
- If phase brief is a stub (no real tasks): suggest running the planner agent first.
- If `.active_ticket` not found: suggest `/aidd-new-ticket`.

## Quality gate

`TASKLIST_READY` (read-only) — does not advance state.
