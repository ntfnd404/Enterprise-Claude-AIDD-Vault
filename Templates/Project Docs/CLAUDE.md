# CLAUDE.md (project template)

> **CLAUDE.md hygiene rule.** Project `CLAUDE.md` contains only what breaks Claude without explicit instruction. Everything else — conventions, code style, architecture, lane definitions, runbooks — belongs in skills, hooks, `docs/project/`, or workflow docs. If a rule could live elsewhere, it should.

## Key documents

- `docs/project/conventions.md` — architecture and package rules
- `docs/project/code-style-guide.md` — formatting, naming, imports
- `docs/project/workflow.md` — AIDD methodology pointer
- `docs/project/guidelines.md` — stack-specific guidance

---

## Project overview

<!-- 1–2 sentences on what the project does. Deeper detail belongs in conventions.md or architecture.md. -->

---

## Runtime defaults

- Workflow Version: 3
- Workflow Minor: 3.2
- Default lane: `Professional`
- Mandatory `Critical` lane for: <!-- list project-specific risk domains, e.g. auth, crypto, secrets, storage migrations, API contracts -->
- `Trivial` lane available — see canonical definition in vault `Methodology/Lanes.md`.

---

## First session checks

- `/config`
- `/agents`
- `/hooks`
- `/mcp`
- `claude --version`

## Before code changes

1. Read `docs/<TICKET>/.active_ticket`
2. Read the phase brief, plan, and PRD for the current phase
3. Verify lane and gate requirements
4. Propose the next batch and wait for explicit approval

## After code changes

1. Run `/aidd-run-checks`
2. Run the phase checks required by the lane
3. Update the phase brief and tasklist
4. Show the diff and explain the completed batch
5. Stop on a meaningful boundary
