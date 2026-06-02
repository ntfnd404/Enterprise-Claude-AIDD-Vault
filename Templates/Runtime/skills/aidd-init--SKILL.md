---
name: aidd-init
description: Bootstrap AIDD v3 workflow in a new or existing project. Creates .claude/ runtime, docs/project/ structure, CLAUDE.md, AGENTS.md.
allowed-tools: Read, Write, Bash, Glob, Grep
disable-model-invocation: true
---

# AIDD Init

Bootstrap the AIDD v3 workflow in the current project directory.

**VAULT**: The AIDD vault is at `~/Documents/Obsidian/Enterprise Claude AIDD Vault` (or `$AIDD_VAULT` if set). All files MUST be copied verbatim from vault templates — do NOT generate, invent, or paraphrase any content.

## Arguments

$ARGUMENTS

Parse the arguments above:
- `--tier <lite|standard|enterprise>` — tier level (default: `standard`)
- `--adaptor <flutter-dart|custom>` — tech stack adaptor (default: none)
- `--prefix <PREFIX>` — ticket prefix, e.g. `VA`, `BW` (default: `PROJ`)
- `--adopt` — adopt mode for existing projects (scan + merge, no overwrite)

## Source of Truth

Every file created by this skill MUST be read from the vault first and copied as-is:

| What to create | Copy from vault |
|---|---|
| `.claude/agents/*.md` | `<VAULT>/Templates/Runtime/agents/` |
| `.claude/skills/*/SKILL.md` | `<VAULT>/Templates/Runtime/skills/` |
| `.claude/hooks/*.sh` | `<VAULT>/Templates/Runtime/hooks/` |
| `.claude/bin/aidd_validate.sh` | `<VAULT>/Templates/Runtime/bin/aidd_validate.sh` |
| `.claude/settings.json` | `<VAULT>/Templates/Runtime/settings.json` |
| `docs/project/workflow.md` | `<VAULT>/Templates/Project Docs/workflow.md` |
| `docs/project/conventions.md` | `<VAULT>/Templates/Project Docs/conventions.md.stub` |
| `docs/project/code-style-guide.md` | `<VAULT>/Templates/Project Docs/code-style-guide.md.stub` |
| `docs/project/guidelines.md` | `<VAULT>/Templates/Project Docs/guidelines.md.stub` |
| `docs/project/templates/*.md` | `<VAULT>/Templates/Artifacts/` |
| `CLAUDE.md` | `<VAULT>/Templates/CLAUDE.md.template` |
| `AGENTS.md` | `<VAULT>/Templates/AGENTS.md.template` |

**Never invent file content.** If a source file cannot be found in the vault, report the missing path and skip that file.

## Tier Filtering

After copying, remove files not included in the requested tier:

**Lite** — keep only: `analyst`, `planner`, `implementer`, `reviewer`, `qa` agents; `aidd-init`, `aidd-new-ticket`, `aidd-start-phase`, `aidd-run-checks`, `aidd-ship-feature` skills; 6 hooks (no SubagentStart/Stop, no team mode hooks).

**Standard** — keep all 7 agents, all 8 skills, 10 hooks (no team mode hooks).

**Enterprise** — keep everything.

## Adaptor

If `--adaptor flutter-dart` is specified, additionally:
1. Read `<VAULT>/Tech Adaptors/Flutter-Dart/conventions-overlay.md` → append to `docs/project/conventions.md`
2. Read `<VAULT>/Tech Adaptors/Flutter-Dart/code-style-overlay.md` → append to `docs/project/code-style-guide.md`
3. Copy `<VAULT>/Tech Adaptors/Flutter-Dart/post-edit-format.sh` → `.claude/hooks/post-edit-format.sh`
4. Add PostToolUse hook entry to `.claude/settings.json` pointing to `post-edit-format.sh`
5. Read `<VAULT>/Tech Adaptors/Flutter-Dart/mcp-config.md` → generate `.mcp.json` skeleton
   - `.mcp.json` contains both `dart` and `dcm` MCP servers
   - **If automatic creation is blocked by permissions**: show the file contents to the user
     and ask them to create it manually or add a Write permission for `.mcp.json`
6. Read `<VAULT>/Tech Adaptors/Flutter-Dart/run-checks-overlay.md`
   → extract the `## Generated aidd-checks.sh` code block → `.claude/aidd-checks.sh`
   → `chmod +x .claude/aidd-checks.sh`
   This enables `/aidd-run-checks` to work. Without it the skill always fails with "no check pipeline".
7. Read `<VAULT>/Tech Adaptors/Flutter-Dart/external-skills-overlay.md`
   → install skills marked "Полностью применимы" and "Применимы с оговорками" (16 total):
     For each skill name, copy `<SKILLS_VAULT>/Catalog/<Flutter|Dart>/<skill-name>.md`
     → `.claude/skills/<skill-name>/SKILL.md`
   where `<SKILLS_VAULT>` = `~/Documents/Obsidian/Skills/Skills`
   → copy `external-skills-overlay.md` → `docs/project/external-skills.md`
   → copy `gate-skill-matrix.md`       → `docs/project/gate-skill-matrix.md`
   **Do NOT install** skills marked "Неприменимы в текущем проекте".

## Template Substitution

In `CLAUDE.md` and `AGENTS.md`, replace:
- `<PROJECT_NAME>` → current directory name
- `<PREFIX>` → value from `--prefix`
- `<TIER>` → value from `--tier`

In `.claude/settings.json` and hook scripts, set:
- `AIDD_TIER` → value from `--tier`
- `AIDD_PROJECT_PREFIX` → value from `--prefix`

## Adopt Mode

When `--adopt` is passed:
1. Scan `.claude/` and `docs/project/` — list what exists
2. Compare against the required file list above
3. Report missing files
4. Copy only missing files from vault (never overwrite existing)
5. Run validate and report

## Optional Git Pre-Commit Hook

The vault includes `<VAULT>/Templates/Runtime/hooks/git-pre-commit.sh` — an OPTIONAL local enforcement layer that runs `aidd_validate.sh` before every commit. It is NOT part of the Claude Code hook system and is NOT installed automatically.

After scaffolding, copy it into `.claude/hooks/` so it's available to the project, then mention to the user how to install it:

```sh
cp .claude/hooks/git-pre-commit.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

Each developer opts in per-clone.

## After Creating Files

1. Run `.claude/bin/aidd_validate.sh` — fix any reported issues
2. Print a summary: files created, tier, adaptor applied, next step (`/aidd-new-ticket <PREFIX>-0001`)
3. Mention the optional git-pre-commit installation command (above)
