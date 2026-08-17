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

Before running this skill:
- a `Trivial` ticket has exactly one ticket-level review at
  `docs/<TICKET>/review/<TICKET>-review.md` with matching Ticket/Lane metadata,
  `Status: REVIEW_OK`, and verdict `REVIEW_OK`, and has no phase, plan, PRD,
  research, vision, QA, or security artifact;
- a `Professional` or `Critical` ticket has `REVIEW_OK` and `QA_PASS` for
  every declared phase;
- every `Critical` phase has `SECURITY_REVIEW_OK`;
- validator passes cleanly;
- the ticket appears exactly once under `## In-flight tickets` in
  `docs/project/roadmap.md`.

## Steps

1. Locate `<TICKET>`: read the first match of `docs/*/.active_ticket` via Glob.
2. Read `docs/<TICKET>/idea-<TICKET>.md` and determine its exact `Lane`.
3. Read `docs/<TICKET>/tasklist-<TICKET>.md`:
   - for `Trivial`, verify the single work row is complete;
   - otherwise, verify all phases show completed status in the Progress table;
   - verify all release readiness items are checked.
4. If the lane is `Trivial`:
   - require exactly one ticket-level review candidate and require its exact
     path to be `docs/<TICKET>/review/<TICKET>-review.md`;
   - require matching `Ticket: <TICKET>` and `Lane: Trivial` metadata,
     `Status: REVIEW_OK`, and verdict `REVIEW_OK`;
   - require no phase briefs, phase review summaries, plans, PRDs, research,
     vision, QA records, or security review records.
5. Otherwise, extract the exact declared phase-number set from the phase
   briefs and:
   - require review records at
     `docs/<TICKET>/review/<TICKET>-phase-*-review.md` to match that exact set and
     verify each has `Status: REVIEW_OK`;
   - require QA records at `docs/<TICKET>/qa/<TICKET>-phase-*-qa.md` to match that
     exact set and verify each has verdict `QA_PASS`;
   - for every `Critical` phase, require security reviews at
     `docs/<TICKET>/security/<TICKET>-phase-*-security.md` to match the exact Critical
     phase set and verify each has `SECURITY_REVIEW_OK`.
6. Run `.claude/bin/aidd_validate.sh` — must pass with 0 failures.
7. Read the lane-required review, security, and QA artifacts for unresolved
   follow-ups.
   - Every intentionally deferred follow-up must already have a `BL-NNN`
     entry in `## Planned` or `## Deferred / open items`.
   - Abort rather than losing an out-of-scope finding.
8. Read `docs/<TICKET>/metrics.log` if it exists. It is optional for Trivial.
9. Promote durable learnings and confirm persistent documentation is current.
10. Require the existing primary implementation PR to be open as draft and
    record its number. Trivial may have created it through the exact reviewed
    delivery bundle; other lanes retain separate push and PR approvals.
11. Review the complete workspace for credentials, private keys, personal
    email, raw SQL dumps, and private response bodies. Resolve every hit before
    continuing.
12. Require `docs/archive/<TICKET>/` not to exist, remove the sole
    `.active_ticket`, and move the full workspace to that archive path.
13. Add exactly one entry for `<TICKET>` to `docs/archive/README.md`, pointing
    to its primary archived record and including the primary PR reference.
14. Move `<TICKET>` from `## In-flight tickets` to
    `## Completed tickets`.
    - Record a one-line outcome.
    - Record the primary PR reference; the branch is not yet claimed merged.
    - Never link directly to an active or archived workspace.
    - Update `Last reviewed` and prepend a `Last 3 changes` entry, retaining at
      most three entries.
15. Run `.claude/bin/aidd_validate.sh` again after the archive/index/roadmap
    transition.
16. Show the full marker-free diff and status.
    - For Trivial, display an exact closeout bundle naming the archive commit
      message, branch, push target, CI prerequisite, and mark-ready action. One
      affirmative response authorizes only that displayed list.
    - For Professional/Critical, obtain separate commit and push permissions.
17. Produce the three outputs below. For Trivial, append them to the sole
    ticket-level review instead of creating a separate ship artifact. For other
    lanes, use the ticket's established ship record.

## Trivial approval bundles

Before the draft PR exists, the reviewed delivery boundary may display the
exact delivery bundle defined in `docs/project/workflow.md`: commit, push the
named feature branch, and create the named draft PR. After the marker-free diff
is reviewed, this skill displays the closeout bundle described in step 16.

After successful final CI, request a separately visible merge/cleanup bundle
that names the PR, expected head/base, squash merge, `main`/post-merge CI
verification, exact remote feature-branch deletion, and upstream removal while
retaining the local branch. A failure or mismatch stops remaining actions and
requires a newly displayed bundle; do not infer retry authority.

### Output 1: Release readiness checklist

```text
## Release readiness: <TICKET>

- [x] Lane-required work complete
- [x] Lane-required reviews passed
- [x] QA passed (Professional/Critical; N/A for Trivial)
- [x] Security reviews passed (Critical; N/A otherwise)
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

Based on `metrics.log` and the lane-required review artifacts:
- work or phases completed
- lane used
- QA failures and rework count
- key learnings

## Archive rules

- `docs/<TICKET>/` exists only while active. Completed marker-free evidence is
  merged at `docs/archive/<TICKET>/` through the primary PR.
- Durable learnings (ADRs, convention updates, style guide updates) must live in `docs/project/`.
- Durable work status and carry-forwards must live in
  `docs/project/roadmap.md`; never link the roadmap directly to active or
  archived ticket workspace files.
- `docs/archive/README.md` is the sole archive navigation index.
- Do not create routine cleanup/restoration commits, a local-only final archive,
  or a separate archive closeout PR.
- Post-merge CI/deployment systems are authoritative for runtime evidence. A
  later material archive correction uses a normal reviewed docs PR.

## Error handling

- If a Trivial review is missing, duplicated, mismatched, or not `REVIEW_OK`,
  or if phase/plan/PRD/research/vision/QA/security evidence exists for a Trivial
  ticket: report the exact conflict and abort.
- If any Professional/Critical phase is not `QA_PASS`: list incomplete phases
  and abort.
- If review, QA, or required Critical security phase numbers do not exactly
  match declared phases: list missing/extra numbers and abort.
- If validator fails: report failures and abort.
- If `.active_ticket` not found: abort.
- If a Critical phase lacks security review: list missing reviews and abort.
- If the ticket is not uniquely `In-flight`, or a deferred follow-up is absent
  from the roadmap: report and abort.
- If the archive destination or index entry already exists: abort before moving
  any file.
- If post-transition validation fails: atomically move the workspace back to
  `docs/<TICKET>/`, restore `.active_ticket`, the previous index, In-flight
  roadmap entry, and change log before reporting.

## Quality gate

`QA_PASS` (+ `SECURITY_REVIEW_OK` for Critical) → `RELEASE_READY` → `DOCS_UPDATED`
