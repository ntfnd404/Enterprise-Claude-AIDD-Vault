---
name: aidd-new-ticket
description: Create a new feature workspace with workflow-v3 metadata-bearing stubs.
argument-hint: "ticket-id"
disable-model-invocation: true
allowed-tools: Read Write Glob Grep Bash
---

# AIDD New Ticket

Creates the initial workspace for a new feature ticket.

## Usage

```text
/aidd-new-ticket <PREFIX>-NNNN
```

## Steps

1. Parse argument as `<TICKET>` (e.g. `PROJ-0042`). Abort if missing.
2. Verify branch naming: current branch should be `<TICKET>-<kebab-description>` or the user should create it first.
3. Check `docs/<TICKET>/` does not already exist. Abort if it does — never overwrite a workspace.
4. Read templates:
   - `docs/project/templates/idea.md`
   - `docs/project/templates/tasklist.md`
5. Create directory `docs/<TICKET>/`
6. Create `docs/<TICKET>/.active_ticket` containing only `<TICKET>`.
7. Create `docs/<TICKET>/idea-<TICKET>.md` from the idea template with substitutions:

   | Field | Value |
   |-------|-------|
   | `<TICKET-ID>` | `<TICKET>` |
   | `<Feature Name>` | leave as placeholder for the user |
   | `Date` | today's `YYYY-MM-DD` |
   | `Lane` | `Professional` (default; user must verify) |
   | `Workflow Version` | `3` |
   | `Owner` | `Product / Architect` |

8. Create `docs/<TICKET>/tasklist-<TICKET>.md` from the tasklist template with substitutions:

   | Field | Value |
   |-------|-------|
   | `<TICKET-ID>` | `<TICKET>` |
   | `<Feature Name>` | leave as placeholder |
   | `Lane` | `Professional` |
   | `Workflow Version` | `3` |
   | `Owner` | `Planner` |
   | `Context` paths | `docs/<TICKET>/idea-<TICKET>.md` and `docs/<TICKET>/vision-<TICKET>.md` |

9. Create empty subdirectories:
   - `docs/<TICKET>/phase/<TICKET>/`
   - `docs/<TICKET>/plan/`
   - `docs/<TICKET>/prd/`
   - `docs/<TICKET>/research/`
   - `docs/<TICKET>/qa/`
   - `docs/<TICKET>/security/`
10. Report created files and remind the user to:
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
- If no argument provided: ask the user for the ticket ID.
- If templates are missing: report missing template paths and abort.

## Quality gate

`→ IDEA_READY` after the user fills the idea document.
