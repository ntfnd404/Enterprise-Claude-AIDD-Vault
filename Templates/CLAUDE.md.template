# CLAUDE.md

## Key Documents

- **[docs/project/conventions.md](./docs/project/conventions.md)** — architecture and package rules
- **[docs/project/code-style-guide.md](./docs/project/code-style-guide.md)** — formatting, naming, import rules
- **[docs/project/workflow.md](./docs/project/workflow.md)** — Claude-Native Enterprise AIDD v3
- **[docs/project/agent-runtime.md](./docs/project/agent-runtime.md)** — Codex/Claude interoperability
- **[docs/project/guidelines.md](./docs/project/guidelines.md)** — framework-specific guidance

---

## Project Overview

<!-- <PROJECT_DESCRIPTION> -->

---

## Runtime Defaults

- Workflow version: `3`
- Workflow minor: `3.3`
- Runtime model: `Claude-native`
- Default lane: `Professional`
- Tier: `<TIER>`
- Mandatory `Critical` lane for: <!-- <CRITICAL_TRIGGERS> -->

Runtime sources of truth:

- `.claude/settings.json`
- `.claude/agents/`
- `.claude/skills/`
- `CLAUDE.md`

---

## Repository Owner Approval

- Propose each implementation batch and wait for approval.
- For Professional/Critical, before the first code batch, present and obtain owner acceptance of the
  complete specification-only diff, then request permission and create its
  checkpoint commit. Pause implementation if commit permission is not granted.
- Commit later specification amendments separately before continuing affected
  code; never combine the initial specification and implementation baseline.
- Leave changes unstaged until the owner has reviewed them.
- Never run `git commit` or `git push` without the owner's explicit permission.
  For Trivial, one affirmative response to an exact displayed delivery or
  closeout bundle authorizes only its listed commit/push/PR actions.
- Never delete local Git branches; retain them for historical inspection.
- A remote feature branch may be deleted only after its merge into `main` has
  been verified.
- Never mutate deployment, production, data, GitHub, or other external resources unless the
  approved ticket batch explicitly authorizes it.

For Trivial Fast Path eligibility, compact artifacts, proportional checks,
bundle definitions, stop conditions, and reclassification, follow
`docs/project/workflow.md`. Merge remains a separately requested decision; a
generic bundle never authorizes infrastructure mutation.

---

## Before Code Changes

1. Read `docs/project/conventions.md`
2. Read `docs/project/workflow.md`
3. Read `docs/project/agent-runtime.md`
4. Read `docs/<TICKET>/.active_ticket`
5. Determine the lane from the Idea.
6. For Professional/Critical, read the phase brief, plan, and PRD and verify the
   accepted specification checkpoint.
7. For Trivial, verify compact artifacts and absence of phase scaffolding.
8. Check lane and gate requirements.
9. Propose the next batch and wait for explicit approval.

---

## After Code Changes

1. Run `/aidd-run-checks`
2. Run the phase checks required by the lane
3. Update the phase brief and tasklist for Professional/Critical, or the compact
   tasklist/review for Trivial.
4. Show the diff and explain the completed batch
5. Stop on a meaningful boundary

---

## Documentation Layout

- `docs/project/` — persistent source of truth
- `docs/<TICKET>/` — active feature workspace with `.active_ticket`
- `docs/archive/<TICKET>/` — completed marker-free historical evidence merged
  through the ticket's primary PR
- `docs/archive/README.md` — archive navigation; roadmap entries do not link to
  individual workspaces

Core commands:

- `/aidd-new-ticket`
- `/aidd-new-phase`
- `/aidd-start-phase`
- `/aidd-run-checks`
- `/aidd-complete-phase`
- `/aidd-validate`
- `/aidd-ship-feature`
- `/aidd-init`
