# Agent Runtime

Workflow Version: 3
Workflow Minor: 3.4
Last reviewed: YYYY-MM-DD

## Purpose

Projects initialized from this Vault may be developed through both Codex and
Claude Code. The tools use
different native instruction-discovery mechanisms but must follow the same AIDD
ticket state, lane, gates, project conventions, and owner-approval rules.

## Entry points

| Tool | Automatic entry point | Native workflow integration |
|------|-----------------------|-----------------------------|
| Codex | `AGENTS.md` | Codex instructions and explicit execution of documented AIDD steps |
| Claude Code | `CLAUDE.md` | `.claude/agents`, `.claude/skills`, `.claude/hooks`, and slash commands |

Codex does not treat `.claude/skills` or `.claude/hooks` as native Codex
integrations. It may read those files to reproduce the documented procedure,
but must not claim that a Claude hook or slash command ran automatically.

The AIDD failure-diagnosis workflow has native entry points in both tools:

- Claude Code: `/aidd-diagnose-failure [phase-number] [failure-summary]` from
  `.claude/skills/aidd-diagnose-failure/SKILL.md`.
- Codex: `$aidd-diagnose-failure`, discovered from
  `~/.agents/skills/aidd-diagnose-failure/SKILL.md`. Keep the containing skill
  directory as a symlink to the Codex adapter under
  `Templates/Runtime/codex-skills/`; the adapter
  loads the canonical AIDD protocol and exists only to remove Claude-specific
  frontmatter that Codex does not accept. Codex runtimes that still discover
  user skills only from `~/.codex/skills` require a second directory symlink
  there to the same adapter; keep both until the installed runtime discovers
  `.agents`.

## Shared sources of truth

Both tools read and update:

- `docs/project/vision.md` for product identity and non-goals.
- `docs/project/architecture.md` and ADRs for architecture decisions.
- `docs/project/conventions.md` and `code-style-guide.md` for binding rules.
- `docs/project/workflow.md` for lanes, gates, and artifact flow.
- `docs/project/roadmap.md` for durable ticket lifecycle.
- `docs/<TICKET>/` for the active ticket's temporary execution artifacts.
- `docs/archive/<TICKET>/` for marker-free completed-ticket history; archived
  artifacts never override `docs/project/`.

Tool entry files should point to these documents instead of duplicating their
full contents.

## Equivalent workflow behavior

Whether a Professional/Critical batch runs in Codex or Claude Code:

1. Resolve the active ticket and current phase.
2. Read the phase brief, plan, PRD, conventions, and applicable research.
3. Confirm the lane and current gate.
4. Propose a small batch and wait for owner approval.
5. Before the first code batch, show the complete specification-only diff,
   obtain owner acceptance, and create a separately authorized specification
   checkpoint commit. Pause if commit permission is not granted.
6. Implement only the approved batch. Commit any later specification amendment
   separately before continuing affected code.
7. Run the phase checks and record evidence.
8. Update phase/tasklist state and show the diff.
9. Stop at a meaningful review boundary.

On `QA_FAIL`, a flaky test, runtime bug, or unexplained check failure, both
tools run the equivalent read-only `aidd-diagnose-failure` protocol before a
new fix batch is proposed. A changed specification assumption returns to
research/planning; a confirmed in-scope cause still requires owner approval for
the proposed fix batch.

For Trivial, both tools use the Fast Path in `docs/project/workflow.md`: compact
Idea/tasklist/review artifacts, no phase scaffolding or specification checkpoint,
focused checks plus one full implementation gate, and exact owner-visible
delivery/closeout/merge bundles. Both tools must proactively explain why the
task qualifies, what they will skip, and what they retain. Scope growth stops
the batch and routes it back through the appropriate standard lane.

At final ship, both tools use the same primary-PR archive transition: verify
phase evidence and sensitive-content boundaries, remove the active marker, move
the workspace under `docs/archive/`, update the shared archive index and
roadmap, validate, and deliver the final commit through the existing primary
PR. Neither tool creates a routine cleanup/restoration pair or local-only final
archive.

The tool may not skip a gate merely because a native integration is
unavailable. It must execute the equivalent documented check or report the
missing capability as a blocker.

## Repository owner controls

- Keep changes unstaged until owner review.
- `git commit` and `git push` require explicit owner permission. For Trivial,
  an affirmative response to an exact displayed delivery or closeout bundle is
  that permission for only the enumerated actions and targets.
- Merge remains a separately displayed owner decision. A Trivial merge/cleanup
  bundle may condition verified remote-branch deletion on successful merge and
  post-merge CI while retaining the local branch.
- Local Git branches are retained permanently for historical inspection.
- Remote feature branches may be deleted after their merge into `main` is
  verified.
- External mutations, including deployment, production, data, and GitHub configuration,
  require an explicitly approved ticket batch.

## References

- AIDD source vault: `Enterprise Claude AIDD Vault`
- Codex instruction discovery:
  <https://learn.chatgpt.com/docs/agent-configuration/agents-md>
