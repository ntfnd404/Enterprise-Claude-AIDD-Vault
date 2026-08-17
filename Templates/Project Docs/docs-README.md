# Project documentation

Durable project decisions live under `docs/project/`.

- `vision.md` defines the product and its non-goals.
- Project-specific architecture, security, testing, and operations documents
  define their corresponding durable decisions when present.
- `agent-runtime.md` maps AIDD to Codex and Claude Code.
- `roadmap.md` is the durable ticket lifecycle record.
- `adr/` records accepted architectural decisions and their rationale.
- `templates/` contains the AIDD v3 artifact templates copied from the vault.

An active ticket workspace lives at `docs/<TICKET>/` and contains the sole
`.active_ticket` marker. At ship, the marker is removed and the workspace moves
to `docs/archive/<TICKET>/` in the ticket's primary pull request.

Future Trivial tickets use the proportional Fast Path in `project/workflow.md`:
compact Idea/tasklist/review evidence, no phase scaffolding, one full
implementation gate, reduced docs-only closeout checks, and exact
owner-authorized delivery/closeout/merge bundles.

Completed archives are historical execution evidence, not durable sources of
truth. Navigate them through `docs/archive/README.md`; roadmap entries do not
link to active or archived workspaces.
