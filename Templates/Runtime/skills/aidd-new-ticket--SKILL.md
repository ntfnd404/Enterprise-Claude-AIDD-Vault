---
name: aidd-new-ticket
description: Promote roadmap work and create a workflow-v3 feature workspace.
argument-hint: "ticket-id [backlog-id] [--trivial]"
disable-model-invocation: true
allowed-tools: Read Write Glob Grep Bash
---

# AIDD New Ticket

Creates the initial workspace for a new feature ticket.

## Usage

```text
/aidd-new-ticket <PREFIX>-NNNN [BL-NNN] [--trivial]
```

## Steps

1. Parse `<TICKET>` (for example `PROJ-0042`), optional `<BACKLOG>`, and
   optional `--trivial`. Abort if the ticket is missing. Lane defaults to
   `Professional`; `--trivial` selects `Trivial` only after the owner accepts
   the Fast Path proposal from `docs/project/workflow.md`.
2. Read `docs/project/roadmap.md`.
   - Without a backlog argument, require `<TICKET>` in `## Planned`.
   - With `<BACKLOG>`, require it in `## Planned` or
     `## Deferred / open items` for Professional/Critical.
   - For an owner-approved Trivial task, a new unscheduled `<BACKLOG>` may be
     absent from the roadmap only when its identifier is unused everywhere.
     Treat registration and immediate promotion as one atomic primary-branch
     transition; the final roadmap contains only
     `<TICKET> (from <BACKLOG>)` under In-flight.
   - Abort if either identifier already appears in another lifecycle section.
3. Verify branch naming: current branch should be
   `<TICKET>-<kebab-description>` or the user should create it first.
4. Check neither `docs/<TICKET>/` nor `docs/archive/<TICKET>/` exists. Abort if
   either exists — never overwrite an active workspace or reuse an archived
   ticket ID.
5. Read and validate templates:
   - `docs/project/templates/idea.md`
   - for Trivial: `docs/project/templates/trivial_tasklist.md`
   - otherwise: `docs/project/templates/tasklist.md`
6. Move the selected roadmap entry to `## In-flight tickets`.
   - A ticket entry keeps its existing scope.
   - A promoted backlog entry becomes
     `<TICKET> (from <BACKLOG>) — <existing scope>`.
   - Update `Last reviewed` and prepend a `Last 3 changes` entry, retaining at
     most three entries.
   - For Trivial, registration and activation may be introduced together in
     this primary ticket branch and PR. Do not require or create a roadmap-only
     PR.
7. Create directory `docs/<TICKET>/`
8. Create `docs/<TICKET>/.active_ticket` containing only `<TICKET>`.
9. Create `docs/<TICKET>/idea-<TICKET>.md` from the idea template with substitutions:

   | Field | Value |
   |-------|-------|
   | `<TICKET-ID>` | `<TICKET>` |
   | `<Feature Name>` | leave as placeholder for the user |
   | `Date` | today's `YYYY-MM-DD` |
   | `Lane` | selected lane (`Professional` default or explicit `Trivial`) |
   | `Workflow Version` | `3` |
   | `Owner` | `Product / Architect` |

10. Create `docs/<TICKET>/tasklist-<TICKET>.md` from the lane-appropriate
    tasklist template with substitutions:

   | Field | Value |
   |-------|-------|
   | `<TICKET-ID>` | `<TICKET>` |
   | `<Feature Name>` | leave as placeholder |
   | `Lane` | selected lane |
   | `Workflow Version` | `3` |
   | `Owner` | `Planner` |
   | `Context` paths | Trivial: Idea only; otherwise Idea and Vision |

11. Always create `docs/<TICKET>/review/`. For Professional/Critical, also
    create empty subdirectories:
   - `docs/<TICKET>/phase/`
   - `docs/<TICKET>/plan/`
   - `docs/<TICKET>/prd/`
   - `docs/<TICKET>/research/`
   - `docs/<TICKET>/qa/`
   - `docs/<TICKET>/security/`
    For Trivial, create only `review/` from this directory set and do not create
    phase, plan, PRD, research, vision, QA, or security artifacts.
12. Report the roadmap transition and created files, then:
    - verify or change the `Lane` field
    - fill the idea: problem, business goal, scope, stories, acceptance criteria
    - for Trivial, propose one bounded implementation batch and use the compact
      baseline without a separate specification checkpoint;
    - otherwise, run the analyst/researcher/planner flow.

## Branch convention

```sh
git checkout -b <TICKET>-<kebab-description>
```

Create the branch before running this skill if it does not exist.

For Trivial, the branch is the primary implementation branch. A separate
roadmap-only branch or PR is prohibited.

## Error handling

- If `docs/<TICKET>/` already exists: report and abort, do not overwrite.
- If `docs/archive/<TICKET>/` already exists: report that the ticket is already
  completed and abort; do not reuse or overwrite the archived ID.
- If `docs/project/roadmap.md` is missing: report and abort.
- If the ticket/backlog item is absent from the expected roadmap section:
  report and abort, except for the explicit new-unscheduled Trivial transition
  in step 2; otherwise register or triage the work first.
- If no argument provided: ask the user for the ticket ID.
- If `--trivial` is requested for ambiguous scope, a Critical trigger, new
  dependency, schema/public contract, deployment, production, or external
  mutation: reject the flag and route to Professional/Critical.
- If templates are missing: report missing template paths and abort.
- If workspace creation fails after the roadmap transition: remove partial
  workspace files and restore the original roadmap entry before reporting.

## Quality gate

Trivial: accepted compact Idea/tasklist and batch → implementation may begin.

Professional/Critical: `→ IDEA_READY` after the user fills the Idea document.
