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

## Trivial Fast Path

Use the Fast Path only for a bounded, low-risk change whose behavior and
verification fit in one small batch. It is disallowed for every Critical
trigger, ambiguous or expanding scope, new dependencies, schema/storage/public
contract changes, production/deployment changes, or external-resource
mutation. When uncertain, use Professional.

Before work begins, the agent says that the task appears Trivial, proposes the
shortened path, lists the steps it will skip and retain, and waits for owner
approval. Scope growth invalidates the Fast Path: stop, reclassify to
Professional or Critical, complete the standard specification checkpoint, and
only then continue.

### Artifacts and baseline

A Trivial ticket does not create phase briefs, phase review summaries, QA
records, security review records, plans, PRDs, research, or vision. Its minimum
active workspace contains:

- `.active_ticket`;
- `idea-<TICKET>.md`;
- `tasklist-<TICKET>.md`;
- `review/<TICKET>-review.md` after implementation.

A factual `metrics.log` is optional. Other separate execution/ship artifacts
are not required.

The accepted batch proposal plus compact Idea/tasklist is the Trivial
specification baseline. It does not require a separate specification checkpoint
commit. Backlog registration and activation travel in the primary ticket branch
and PR; do not create a roadmap-only PR.

At release readiness the single ticket-level review must carry matching
`Ticket` and `Lane: Trivial` metadata, `Status: REVIEW_OK`, and a `REVIEW_OK`
verdict. Append release readiness, docs sync, retrospective, and delivery/
rollback references to that review; a separate metrics or ship artifact is
optional, not required.

Professional/Critical phase artifacts use typed basenames:

- `phase/<TICKET>-phase-N-brief.md`;
- `plan/<TICKET>-phase-N-plan.md`;
- `prd/<TICKET>-phase-N-prd.md`;
- `research/<TICKET>-phase-N-research.md`;
- `review/<TICKET>-phase-N-review.md`;
- `qa/<TICKET>-phase-N-qa.md`;
- `security/<TICKET>-phase-N-security.md` for Critical.

Each phase has exactly one canonical review. Remediation and later review
rounds update that file; Git preserves its history. Active/future work does not
use a nested `phase/<TICKET>/` directory. Historical archives retain their
original paths.

### Proportional checks

- Run every focused check named by the tasklist and one full `make check` before
  `REVIEW_OK`.
- After a reviewed implementation, a pure workspace relocation and archive/
  roadmap metadata update requires only formatting, full/quick validator,
  `git diff --check`, and sensitive-content scans.
- Any functional or tooling drift during closeout invalidates the reduced gate;
  rerun focused checks and the full project gate.

### Explicit approval bundles

A bundle is valid only when the agent displays every action, exact target
branch/PR, intended commit message, prerequisites, and stop conditions before
the owner's affirmative response. One response authorizes only that displayed
list. Diff drift, failed checks, identity/SHA mismatch, PR conflict, merge
failure, or CI failure stops all remaining actions; authority is not inferred
for a corrected retry.

1. **Delivery bundle**, after complete implementation diff review: stage the
   exact reviewed paths, create the named commit, push the named feature branch,
   and create its draft PR against the stated base.
2. **Closeout bundle**, after complete marker-free archive diff review: create
   the archive-transition commit, push it to the same PR, wait for successful
   CI, and mark the PR ready.
3. **Merge/cleanup bundle**, requested separately from delivery and closeout:
   squash-merge the ready PR, verify the resulting `main` SHA and post-merge CI,
   then delete only the verified merged remote feature branch and unset its
   upstream while retaining the local branch.

Merge into `main` remains a separately visible owner decision. Generic Trivial
bundles never include cloud, DNS, secrets, data, deployment, production,
or unrelated branch mutations.

## Gates

Trivial:

```text
IDEA_READY → TASKLIST_READY → IMPLEMENT_STEP_OK → REVIEW_OK
→ RELEASE_READY → DOCS_UPDATED
```

Professional/Critical:

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

- Read compact Idea/tasklist for Trivial, or phase/plan/PRD for other lanes
- Propose batch (2-5 related tasks)
- Wait for approval
- Implement
- Run checks
- Update docs
- Show diff
- Stop on meaningful boundary

## Specification Baseline Before Implementation

This section applies to Professional and Critical tickets. Trivial uses the
compact owner-approved baseline above.

`PLAN_APPROVED` and `TASKLIST_READY` make a Professional/Critical specification
reviewable, but do not by themselves authorize code changes. Before the first
implementation batch:

1. Show `git status` and the complete specification-only diff.
2. Obtain explicit owner acceptance of the PRD, research, vision, plan, phase
   brief, and tasklist as one baseline.
3. Request separate permission to commit that specification baseline.
4. Create the specification checkpoint commit before writing implementation
   code.
5. Start implementation only from that committed baseline.

If commit permission is not granted, implementation pauses. Do not mix the
initial specification and its implementation in one commit. If an accepted
requirement changes later, stop the active implementation batch, update and
review the affected artifacts, and commit a specification amendment before
continuing code.

This checkpoint is a mandatory Git boundary, not a replacement for any AIDD
gate. Push still requires its own separate permission.

## Roadmap And Backlog

`docs/project/roadmap.md` is the durable source of truth for completed,
in-flight, planned, and deferred work. Active ticket workspaces under
`docs/<TICKET>/` are temporary execution artifacts. Completed marker-free
workspaces are historical evidence under `docs/archive/<TICKET>/`. Neither is
linked directly from the roadmap; archive navigation lives in
`docs/archive/README.md`.

- New unscheduled work receives a `BL-NNN` identifier.
- Starting a backlog item assigns a ticket and records
  `<TICKET> (from BL-NNN)` in `In-flight`.
- Trivial registration and activation may occur together in its primary branch
  and PR; no roadmap-only PR is required.
- `/aidd-new-ticket` moves planned work to `In-flight`.
- `/aidd-ship-feature` moves gated work to `Completed` with a durable merge,
  PR, or commit reference.
- Cancelled work moves to `Deferred / open items` with a reason.
- Out-of-scope findings must be registered before the current ticket ships.
- Every edit updates `Last reviewed` and `Last 3 changes`.
- A ticket or backlog ID may appear in only one lifecycle section.

## Primary-PR Archive

After all release-readiness gates pass:

1. Open the implementation PR as draft so the primary PR number is available.
   Trivial may use its reviewed delivery bundle; other lanes retain separate
   commit, push, and PR approvals.
2. Verify lane-required evidence: the single ticket-level review for Trivial,
   or exact phase-number coverage for review and QA artifacts and, for a
   Critical lane, security-review artifacts.
3. Promote durable learnings into `docs/project/` and deferred findings into
   the roadmap.
4. Review the workspace for credentials, personal data, raw dumps, and private
   response content.
5. Remove `.active_ticket`, move the workspace to
   `docs/archive/<TICKET>/`, update the archive index, and move the roadmap item
   from In-flight to Completed with the primary PR reference.
6. Validate and push that final ship commit to the same PR. Trivial may use its
   reviewed closeout bundle; other lanes retain separate approvals.

Do not create cleanup commits, restore a local-only archive after merge, or use
a separate routine archive closeout PR. GitHub CI and the deployment platform
remain authoritative for post-merge runtime evidence. A later material
correction to an archive uses a normal reviewed documentation PR.

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
- `docs/<TICKET>/` — active feature workspace with `.active_ticket`
- `docs/archive/<TICKET>/` — completed marker-free historical evidence
- `docs/archive/README.md` — archive navigation

## Workflow Version

`3`
