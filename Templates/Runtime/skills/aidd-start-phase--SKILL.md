---
name: aidd-start-phase
description: Load current phase context and propose the next implementation batch.
argument-hint: "phase-number"
disable-model-invocation: true
allowed-tools: Read Glob Grep Bash
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
4. Verify the specification checkpoint with read-only Git commands:
   - the current branch contains a commit whose exact subject is
     `aidd(<TICKET>): approve phase <N> specification baseline`;
   - that commit is reachable from `HEAD`;
   - immutable specification artifacts (`idea`, `prd`, `critique`, `research`,
     `vision`, and `plan`) have no staged, unstaged, or untracked changes;
   - locate the latest commit whose exact subject is either the baseline subject
     or `aidd(<TICKET>): amend phase <N> specification baseline`;
   - `git diff <latest-checkpoint>..HEAD -- <immutable-spec-paths>` is empty.
     A non-empty diff means committed specification drift exists after the
     checkpoint and implementation must stop, even when the working tree is
     clean.
5. Abort before proposing implementation when the checkpoint is missing or
   immutable specification artifacts are dirty or changed after the latest
   checkpoint. Explain that the owner must
   review the complete specification-only diff, explicitly accept it, authorize
   a separate commit, and complete the checkpoint. Do not create the commit.
6. Record the latest matching baseline/amendment commit SHA for the execution
   summary.
7. Read in order:
   - `docs/<TICKET>/phase/<TICKET>/phase-N.md` — execution packet
   - `docs/<TICKET>/plan/<TICKET>-phase-N.md` — implementation design
   - `docs/<TICKET>/prd/<TICKET>-phase-N.prd.md` — acceptance criteria
   - `docs/project/conventions.md` — architecture rules
   - `docs/project/code-style-guide.md` — style rules
8. Extract from phase brief:
   - `Lane`
   - `Goal`
   - execution checklist items (find first unchecked `- [ ]`)
   - stop conditions
   - acceptance criteria
9. Extract from plan:
   - file changes table
   - sequencing
   - risks
10. Output a concise execution summary in this format:

```text
## Phase N: <goal>

Lane: Professional | Critical
Goal: <one line from phase brief>
Specification checkpoint: <short SHA and commit subject>

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
- The specification checkpoint is a mandatory Git boundary, not a new AIDD
  status.
- Phase brief and tasklist execution-state updates may change during
  implementation; accepted requirement, architecture, scope, and design changes
  belong in immutable specification artifacts and require an amendment commit.

## Error handling

- If phase brief not found: suggest `/aidd-new-phase N`.
- If phase brief is a stub (no real tasks): suggest running the planner agent first.
- If `.active_ticket` not found: suggest `/aidd-new-ticket`.
- If the checkpoint is missing or the immutable specification is dirty: stop
  implementation and point to `docs/project/workflow.md`.

## Quality gate

`TASKLIST_READY` (read-only) — does not advance state.
