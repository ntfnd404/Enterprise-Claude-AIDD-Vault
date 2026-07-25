# Workflow

This project follows **Claude-Native Enterprise AIDD v3**.

## Reference

Full methodology: [Enterprise Claude AIDD Vault](https://obsidian.md)

## Lanes

| Lane | When | Flow |
|---|---|---|
| Trivial | typo, rename, tiny fix | edit → review |
| Professional | features, refactors, new capabilities | idea → prd → research → vision → plan → implement → review → qa |
| Critical | auth, crypto, secrets, storage, migrations, API contracts | Professional + security review |

Default: `Professional`

## Gates

```
IDEA_READY → PRD_READY → RESEARCH_DONE → VISION_APPROVED → PLAN_APPROVED
→ TASKLIST_READY → IMPLEMENT_STEP_OK → REVIEW_OK
→ SECURITY_REVIEW_OK (Critical) → QA_PASS → RELEASE_READY → DOCS_UPDATED
```

## Roles

| Role | Owns |
|---|---|
| Analyst | Phase PRD |
| Researcher | Codebase facts, vision |
| Planner | Plan, brief, tasklist |
| Implementer | Code, phase/tasklist updates |
| Reviewer | Review summary |
| Security Reviewer | Security review (Critical) |
| QA | QA report |

## Batch Model

- Read phase/plan/prd
- Propose batch (2-5 related tasks)
- Wait for approval
- Implement
- Run checks
- Update docs
- Show diff
- Stop on meaningful boundary

## Specification Baseline Before Implementation

`TASKLIST_READY` completes the AIDD planning gates, but does not by itself
authorize source-code changes. Before the first implementation batch:

1. Show the complete specification-only diff: idea, PRD, critique, research,
   vision, plan, phase brief, and tasklist. The review is cumulative from the
   feature branch point, not only the current uncommitted diff.
2. Obtain explicit owner acceptance of that specification.
3. Obtain separate permission to create a Git commit.
4. Commit the accepted specification before changing source code, using:
   `aidd(<TICKET>): approve phase <N> specification baseline`. The checkpoint commit may
   contain only specification files, or be empty when the accepted artifacts
   are already present in earlier preparation commits.
5. Verify that the immutable specification artifacts are clean, then start the
   approved implementation batch.

If commit permission is not granted, implementation pauses. If accepted
requirements, architecture, scope, or the implementation design changes later,
review and commit the amendment separately with
`aidd(<TICKET>): amend phase <N> specification baseline` before continuing affected code.
Execution-state updates to the phase brief and tasklist may remain part of
implementation batches. Never mix the initial specification baseline and its
first implementation changes in one commit. Push permission remains separate
from commit permission.

## Roadmap And Backlog

`docs/project/roadmap.md` is the durable source of truth for completed,
in-flight, planned, and deferred work. Ticket workspaces under `docs/<TICKET>/`
are temporary branch-local execution artifacts and must never be linked from
the roadmap.

- New unscheduled work receives a `BL-NNN` identifier.
- Starting a backlog item assigns a ticket and records
  `<TICKET> (from BL-NNN)` in `In-flight`.
- `/aidd-new-ticket` moves planned work to `In-flight`.
- `/aidd-ship-feature` moves gated work to `Completed` with a durable merge,
  PR, or commit reference.
- Cancelled work moves to `Deferred / open items` with a reason.
- Out-of-scope findings must be registered before the current ticket ships.
- Every edit updates `Last reviewed` and `Last 3 changes`.
- A ticket or backlog ID may appear in only one lifecycle section.


## External Execution Overlays

External skills and plugins may help execute work inside the workflow, but they
do not change gate progression.

| Layer | Role |
|---|---|
| `/aidd-*` | Workflow commands and gate routing |
| `dart-*` / `flutter-*` | Stack-specific execution skills selected by batch type |
| Superpowers | General execution methodology: brainstorming, TDD, debugging, `/execute-plan`, pre-review |

Superpowers `/execute-plan` is allowed only for an approved batch after
`PLAN_APPROVED` / `TASKLIST_READY`. Superpowers code-reviewer is a pre-review,
not `REVIEW_OK`. Critical phases still require `security-reviewer`.

## Documentation

- `docs/project/` — persistent truth (conventions, style, ADR, templates)
- `docs/project/roadmap.md` — durable ticket and backlog lifecycle
- `docs/<TICKET>/` — feature workspace (branch-local, cleaned before merge)

## Workflow Version

`3`
