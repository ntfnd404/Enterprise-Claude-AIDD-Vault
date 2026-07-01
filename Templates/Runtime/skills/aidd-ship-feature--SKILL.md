---
name: aidd-ship-feature
description: Finalize a completed feature for release readiness, docs sync, and merge preparation.
disable-model-invocation: true
allowed-tools: Read Write Glob Grep Bash
---

# AIDD Ship Feature

Finalizes a feature after all phases are complete. Produces release readiness checklist, docs sync checklist, and a short retrospective.

## Usage

```text
/aidd-ship-feature
```

## Prerequisites

Before running this skill, all phases must satisfy:
- every phase has `REVIEW_OK`
- every phase has `QA_PASS`
- every `Critical` phase has `SECURITY_REVIEW_OK`
- validator passes cleanly
- the ticket appears exactly once under `## In-flight tickets` in
  `docs/project/roadmap.md`

## Steps

1. Locate `<TICKET>`: read the first match of `docs/*/.active_ticket` via Glob.
2. Read `docs/<TICKET>/tasklist-<TICKET>.md`:
   - verify all phases show completed status in the Progress table
   - verify all release readiness items are checked
3. Glob all review summaries: `docs/<TICKET>/<TICKET>-phase-*-summary.md`
   - verify each has `Status: REVIEW_OK`
4. Glob all QA records: `docs/<TICKET>/qa/<TICKET>-phase-*.md`
   - verify each has verdict `QA_PASS`
5. Read `docs/<TICKET>/idea-<TICKET>.md` to find the lane.
6. If any phase has `Lane: Critical`:
   - Glob security reviews: `docs/<TICKET>/security/<TICKET>-phase-*.md`
   - verify each Critical phase has `SECURITY_REVIEW_OK`
7. Run `.claude/bin/aidd_validate.sh` — must pass with 0 failures.
8. Read review, security, and QA artifacts for unresolved follow-ups.
   - Every intentionally deferred follow-up must already have a `BL-NNN`
     entry in `## Planned` or `## Deferred / open items`.
   - Abort rather than losing an out-of-scope finding.
9. Read `docs/<TICKET>/metrics.log` if it exists.
10. Move `<TICKET>` from `## In-flight tickets` to
    `## Completed tickets`.
    - Record a one-line outcome.
    - Record the merge target and current commit, PR, or merge reference when
      available.
    - Never link to `docs/<TICKET>/`.
    - Update `Last reviewed` and prepend a `Last 3 changes` entry, retaining at
      most three entries.
11. Run `.claude/bin/aidd_validate.sh` again after the roadmap transition.
12. Produce three outputs:

### Output 1: Release readiness checklist

```text
## Release readiness: <TICKET>

- [x] All phases complete
- [x] All reviews passed
- [x] All QA passed
- [x] Security reviews passed (Critical)
- [x] Validator clean
- [ ] CHANGELOG updated
- [ ] Persistent docs synced
```

### Output 2: Docs sync checklist (promotion)

Promote durable learnings from the feature workspace into persistent docs:

| Source of learning | Promote to |
|---|---|
| New permanent architectural rule | `docs/project/conventions.md` |
| New style decision | `docs/project/code-style-guide.md` |
| New framework guidance | `docs/project/guidelines.md` |
| Architecture decision | `docs/project/adr/ADR-NNN.md` |
| Runtime instruction change | `CLAUDE.md` |
| Workflow improvement | `docs/project/workflow.md` or templates |
| Validator improvement | `.claude/bin/aidd_validate.sh` |
| Deferred or transferred work | `docs/project/roadmap.md` |

### Output 3: Retrospective

Based on `metrics.log` and phase summaries:
- phases completed
- lanes used
- QA failures and rework count
- key learnings

## Cleanup rules

- `docs/<TICKET>/` stays in the feature branch and is never merged into main.
- Durable learnings (ADRs, convention updates, style guide updates) must live in `docs/project/`.
- Durable work status and carry-forwards must live in
  `docs/project/roadmap.md`; never link the roadmap to ticket workspace files.
- Confirm `.gitignore` or merge strategy excludes `docs/<PREFIX>-*/` from main.

## Error handling

- If any phase is not `QA_PASS`: list incomplete phases and abort.
- If validator fails: report failures and abort.
- If `.active_ticket` not found: abort.
- If a Critical phase lacks security review: list missing reviews and abort.
- If the ticket is not uniquely `In-flight`, or a deferred follow-up is absent
  from the roadmap: report and abort.
- If post-transition validation fails: restore the ticket to `In-flight` and
  restore the previous roadmap change log before reporting.

## Quality gate

`QA_PASS` (+ `SECURITY_REVIEW_OK` for Critical) → `RELEASE_READY` → `DOCS_UPDATED`
