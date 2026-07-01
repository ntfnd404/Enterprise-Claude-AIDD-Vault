---
name: aidd-validate
description: Validate workflow assets, runtime config, metadata templates, and detect stale process references.
disable-model-invocation: true
allowed-tools: Read Bash Glob Grep
context: fork
effort: low
---

# AIDD Validate

Runs the repository process validator to check structural integrity of the AIDD workflow layer.

## Usage

```text
/aidd-validate
```

Optional `--quick` for the fast pre-check (file existence + template metadata only).

## Steps

1. Run `.claude/bin/aidd_validate.sh` (or `.claude/bin/aidd_validate.sh --quick`).
2. Capture stdout and exit code.
3. Parse the output for `failures:` and `warnings:` counts.
4. Report results in the structured format below.

## What the validator checks

### File existence
- Shared docs: `CLAUDE.md`, `AGENTS.md`, `docs/README.md`,
  `docs/project/workflow.md`, `docs/project/roadmap.md`
- Hook files: `settings.json`, all hook scripts in `.claude/hooks/`, `aidd_validate.sh`
- Agent files: all 7 agents in `.claude/agents/` (Standard tier)
- Template files: all 10+ templates in `docs/project/templates/`

### Template metadata contract
Every workflow template must contain:
- `Status:` line
- `Ticket:` line
- `Phase:` line
- `Lane:` line
- `Workflow Version: 3` (exact match)
- `Owner:` line

### Hook event coverage
All required events declared in `.claude/settings.json`:
`InstructionsLoaded`, `SessionStart`, `PreToolUse`, `PostCompact`, `FileChanged`, `ConfigChange`, `SubagentStart`, `SubagentStop`, `TaskCreated`, `TaskCompleted`, `TeammateIdle`.

### Skill integrity
Each workflow skill directory must have a `SKILL.md` with:
- `name: aidd-<name>` matching the expected name
- `disable-model-invocation: true`

### Stale reference detection (anti-drift)
- No legacy workspace paths (`docs/feature/`) in shared docs, agents, or skills.
- No legacy slash-command names (`/new-ticket`, `/new-phase`, etc. without the `aidd-` prefix).
- No unsupported frontmatter fields (`compatibility:` in skills, `color:` in agents).

### Roadmap contract
- `Last reviewed` uses `YYYY-MM-DD`.
- Completed, in-flight, planned, deferred, and change-log sections exist.
- A leading ticket or backlog identifier appears in only one entry.
- Roadmap entries never link to branch-local `docs/<TICKET>/` workspaces.

### Active feature docs (warnings)
For every `.active_ticket` file under `docs/`:
- The corresponding idea file must have `Lane:`, `Status:`, and `Workflow Version:` headers.
- The workflow version must be `3`.
- A phase brief at `Status: TASKLIST_READY` must have at least one `[x]` task — otherwise it is a stub mistakenly advanced.

## Output format

```text
## AIDD validation

failures: N
warnings: N

Result: PASS | FAIL
```

If failures > 0: list each `FAIL:` line from the validator output.
If warnings > 0: list each `WARN:` line.

## Error handling

- If `aidd_validate.sh` is not executable: run `chmod +x .claude/bin/aidd_validate.sh` then retry.
- If `grep` is not available: report the missing tool.
- Exit code 1 = validation failures found; any other non-zero = script error.

## Quality gate

Validator clean → eligible for `RELEASE_READY` in `/aidd-ship-feature`.
