---
name: aidd-start-phase
description: Load current phase context and propose the next implementation batch.
argument-hint: "phase-number"
disable-model-invocation: true
allowed-tools: Read Glob Grep
effort: medium
---

# AIDD Start Phase

Loads the current phase execution packet before implementation begins.

## Usage

```text
/aidd-start-phase N
```

## Steps

1. Parse argument as `N` (phase number). Abort if missing.
2. Locate `<TICKET>`: read the first match of `docs/*/.active_ticket` via Glob.
3. Verify the phase brief status is `TASKLIST_READY` or higher. Abort if it is still a stub.
4. Read in order:
   - `docs/<TICKET>/phase/<TICKET>/phase-N.md` — execution packet
   - `docs/<TICKET>/plan/<TICKET>-phase-N.md` — implementation design
   - `docs/<TICKET>/prd/<TICKET>-phase-N.prd.md` — acceptance criteria
   - `docs/project/conventions.md` — architecture rules
   - `docs/project/code-style-guide.md` — style rules
5. Extract from phase brief:
   - `Lane`
   - `Goal`
   - execution checklist items (find first unchecked `- [ ]`)
   - stop conditions
   - acceptance criteria
6. Extract from plan:
   - file changes table
   - sequencing
   - risks
7. Output a concise execution summary in this format:

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
- Always end with an explicit proposal and wait for approval.

## Error handling

- If phase brief not found: suggest `/aidd-new-phase N`.
- If phase brief is a stub (no real tasks): suggest running the planner agent first.
- If `.active_ticket` not found: suggest `/aidd-new-ticket`.

## Quality gate

`TASKLIST_READY` (read-only) — does not advance state.
