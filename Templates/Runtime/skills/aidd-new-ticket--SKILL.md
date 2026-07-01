---
name: aidd-new-ticket
description: Promote roadmap work and create a workflow-v3 feature workspace.
argument-hint: "ticket-id [backlog-id]"
disable-model-invocation: true
allowed-tools: Read Write Glob Grep Bash
---

# AIDD New Ticket

Creates the initial workspace for a new feature ticket.

## Usage

```text
/aidd-new-ticket <PREFIX>-NNNN [BL-NNN]
```

## Steps

1. Parse argument as `<TICKET>` (e.g. `PROJ-0042`). Abort if missing.
2. Read `docs/project/roadmap.md`.
   - Without a backlog argument, require `<TICKET>` in `## Planned`.
   - With `<BACKLOG>`, require it in `## Planned` or
     `## Deferred / open items`.
   - Abort if either identifier already appears in another lifecycle section.
3. Verify branch naming: current branch should be
   `<TICKET>-<kebab-description>` or the user should create it first.
4. Check `docs/<TICKET>/` does not already exist. Abort if it does — never
   overwrite a workspace.
5. Read and validate templates:
   - `docs/project/templates/idea.md`
   - `docs/project/templates/tasklist.md`
6. Move the selected roadmap entry to `## In-flight tickets`.
   - A ticket entry keeps its existing scope.
   - A promoted backlog entry becomes
     `<TICKET> (from <BACKLOG>) — <existing scope>`.
   - Update `Last reviewed` and prepend a `Last 3 changes` entry, retaining at
     most three entries.
7. Create directory `docs/<TICKET>/`
8. Create `docs/<TICKET>/.active_ticket` containing only `<TICKET>`.
9. Create `docs/<TICKET>/idea-<TICKET>.md` from the idea template with substitutions:

   | Field | Value |
   |-------|-------|
   | `<TICKET-ID>` | `<TICKET>` |
   | `<Feature Name>` | leave as placeholder for the user |
   | `Date` | today's `YYYY-MM-DD` |
   | `Lane` | `Professional` (default; user must verify) |
   | `Workflow Version` | `3` |
   | `Owner` | `Product / Architect` |

10. Create `docs/<TICKET>/tasklist-<TICKET>.md` from the tasklist template with substitutions:

   | Field | Value |
   |-------|-------|
   | `<TICKET-ID>` | `<TICKET>` |
   | `<Feature Name>` | leave as placeholder |
   | `Lane` | `Professional` |
   | `Workflow Version` | `3` |
   | `Owner` | `Planner` |
   | `Context` paths | `docs/<TICKET>/idea-<TICKET>.md` and `docs/<TICKET>/vision-<TICKET>.md` |

11. Create empty subdirectories:
   - `docs/<TICKET>/phase/<TICKET>/`
   - `docs/<TICKET>/plan/`
   - `docs/<TICKET>/prd/`
   - `docs/<TICKET>/research/`
   - `docs/<TICKET>/qa/`
   - `docs/<TICKET>/security/`
12. Report the roadmap transition and created files, then remind the user to:
    - verify or change the `Lane` field
    - fill the idea: problem, business goal, scope, stories, acceptance criteria
    - run analyst agent when the idea is ready

## Branch convention

```sh
git checkout -b <TICKET>-<kebab-description>
```

Create the branch before running this skill if it does not exist.

## Error handling

- If `docs/<TICKET>/` already exists: report and abort, do not overwrite.
- If `docs/project/roadmap.md` is missing: report and abort.
- If the ticket/backlog item is absent from the expected roadmap section:
  report and abort; register or triage the work first.
- If no argument provided: ask the user for the ticket ID.
- If templates are missing: report missing template paths and abort.
- If workspace creation fails after the roadmap transition: remove partial
  workspace files and restore the original roadmap entry before reporting.

## Quality gate

`→ IDEA_READY` after the user fills the idea document.
