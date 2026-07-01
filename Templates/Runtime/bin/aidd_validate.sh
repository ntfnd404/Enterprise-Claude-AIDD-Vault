#!/usr/bin/env bash

# AIDD Process Validator
# Validates the workflow layer: shared docs, runtime files, templates,
# slash-command names, and stale references. Does not validate application
# code correctness or business logic.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT_DIR}"

failures=0
warnings=0
quick="${1:-}"

fail() {
  echo "FAIL: $1"
  failures=$((failures + 1))
}

warn() {
  echo "WARN: $1"
  warnings=$((warnings + 1))
}

require_file() {
  local path="$1"
  if [[ ! -f "${path}" ]]; then
    fail "missing file: ${path}"
  fi
}

require_pattern() {
  local path="$1"
  local pattern="$2"
  if ! grep -qE "${pattern}" "${path}" 2>/dev/null; then
    fail "missing pattern '${pattern}' in ${path}"
  fi
}

# ---------------------------------------------------------------------------
# 1. Shared docs and runtime files
# ---------------------------------------------------------------------------

shared_docs=(
  "CLAUDE.md"
  "AGENTS.md"
  "docs/README.md"
  "docs/project/roadmap.md"
  "docs/project/workflow.md"
)

hook_files=(
  ".claude/settings.json"
  ".claude/bin/aidd_validate.sh"
  ".claude/hooks/instructions-loaded.sh"
  ".claude/hooks/session-compact.sh"
  ".claude/hooks/pre-edit-guard.sh"
  ".claude/hooks/post-compact-reinject.sh"
  ".claude/hooks/config-change-guard.sh"
  ".claude/hooks/file-changed-guard.sh"
  ".claude/hooks/subagent-lifecycle.sh"
  ".claude/hooks/team-task-lifecycle.sh"
)

agent_files=(
  ".claude/agents/analyst.md"
  ".claude/agents/researcher.md"
  ".claude/agents/planner.md"
  ".claude/agents/implementer.md"
  ".claude/agents/reviewer.md"
  ".claude/agents/security-reviewer.md"
  ".claude/agents/qa.md"
)

template_files=(
  "docs/project/templates/idea.md"
  "docs/project/templates/vision.md"
  "docs/project/templates/tasklist.md"
  "docs/project/templates/phase_prd.md"
  "docs/project/templates/phase_research.md"
  "docs/project/templates/phase_plan.md"
  "docs/project/templates/phase_brief.md"
  "docs/project/templates/phase_summary.md"
  "docs/project/templates/phase_qa.md"
  "docs/project/templates/phase_security_review.md"
)

extra_template_files=(
  "docs/project/templates/adr.md"
)

workflow_skill_names=(
  "aidd-new-ticket"
  "aidd-new-phase"
  "aidd-start-phase"
  "aidd-run-checks"
  "aidd-complete-phase"
  "aidd-validate"
  "aidd-ship-feature"
  "aidd-init"
)

for path in \
  "${shared_docs[@]}" \
  "${hook_files[@]}" \
  "${agent_files[@]}" \
  "${template_files[@]}" \
  "${extra_template_files[@]}"; do
  require_file "${path}"
done

# ---------------------------------------------------------------------------
# 1a. Durable roadmap contract
# ---------------------------------------------------------------------------

roadmap_path="docs/project/roadmap.md"
if [[ -f "${roadmap_path}" ]]; then
  require_pattern "${roadmap_path}" "^Last reviewed: [0-9]{4}-[0-9]{2}-[0-9]{2}$"
  require_pattern "${roadmap_path}" "^## Completed tickets$"
  require_pattern "${roadmap_path}" "^## In-flight tickets$"
  require_pattern "${roadmap_path}" "^## Planned$"
  require_pattern "${roadmap_path}" "^## Deferred / open items$"
  require_pattern "${roadmap_path}" "^## Last 3 changes$"

  duplicate_roadmap_ids=$(
    grep -E '^- ([A-Z][A-Z0-9]*-[0-9]+|BL-[0-9]{3})([^0-9]|$)' "${roadmap_path}" \
      | sed -E 's/^- (([A-Z][A-Z0-9]*-[0-9]+|BL-[0-9]{3})).*/\1/' \
      | sort \
      | uniq -d \
      || true
  )
  if [[ -n "${duplicate_roadmap_ids}" ]]; then
    fail "roadmap identifiers appear in multiple entries: ${duplicate_roadmap_ids}"
  fi

  ticket_workspace_links=$(
    grep -nE '\]\([^)]*docs/[A-Z][A-Z0-9]*-[0-9]+/' "${roadmap_path}" \
      || true
  )
  if [[ -n "${ticket_workspace_links}" ]]; then
    fail "roadmap links to branch-local ticket workspaces:\n${ticket_workspace_links}"
  fi
fi

# ---------------------------------------------------------------------------
# 2. Template metadata contract
# Every workflow template must carry the v3 metadata header.
# ---------------------------------------------------------------------------

for path in "${template_files[@]}"; do
  require_pattern "${path}" "^Status:"
  require_pattern "${path}" "^Ticket:"
  require_pattern "${path}" "^Phase:"
  require_pattern "${path}" "^Lane:"
  require_pattern "${path}" "^Workflow Version: 3$"
  require_pattern "${path}" "^Owner:"
done

# Quick mode stops here.
if [[ "${quick}" == "--quick" ]]; then
  echo
  echo "AIDD validation summary (quick)"
  echo "failures: ${failures}"
  echo "warnings: ${warnings}"
  [[ ${failures} -eq 0 ]] && exit 0 || exit 1
fi

# ---------------------------------------------------------------------------
# 3. Hook event coverage in settings.json
# ---------------------------------------------------------------------------

hook_events=(
  "InstructionsLoaded"
  "SessionStart"
  "PreToolUse"
  "PostCompact"
  "FileChanged"
  "ConfigChange"
  "SubagentStart"
  "SubagentStop"
  "TaskCreated"
  "TaskCompleted"
  "TeammateIdle"
)

for event_name in "${hook_events[@]}"; do
  require_pattern ".claude/settings.json" "\"${event_name}\""
done

# ---------------------------------------------------------------------------
# 4. Skill integrity
# Each workflow skill must be at .claude/skills/<name>/SKILL.md and carry
# the disable-model-invocation: true frontmatter.
# ---------------------------------------------------------------------------

for skill_name in "${workflow_skill_names[@]}"; do
  skill_path=".claude/skills/${skill_name}/SKILL.md"
  require_file "${skill_path}"
  if [[ -f "${skill_path}" ]]; then
    require_pattern "${skill_path}" "^name: ${skill_name}$"
    require_pattern "${skill_path}" "^disable-model-invocation: true$"
  fi
done

# ---------------------------------------------------------------------------
# 5. Stale references and unsupported fields (anti-drift)
# ---------------------------------------------------------------------------

# Stale legacy workspace paths in shared workflow files.
# Exclude aidd-validate skill dir — it documents the patterns it checks for.
stale_refs=$(
  grep -rn "docs/feature/" \
    AGENTS.md \
    CLAUDE.md \
    docs/README.md \
    docs/project/workflow.md \
    docs/project/templates/ \
    .claude/agents/ \
    .claude/skills/ \
    --exclude-dir=aidd-validate \
    2>/dev/null || true
)
if [[ -n "${stale_refs}" ]]; then
  fail "stale docs/feature references remain:\n${stale_refs}"
fi

# Unsupported skill frontmatter fields.
invalid_skill_fields=$(
  grep -rn "^compatibility:" .claude/skills/*/SKILL.md 2>/dev/null || true
)
if [[ -n "${invalid_skill_fields}" ]]; then
  fail "unsupported skill frontmatter fields remain:\n${invalid_skill_fields}"
fi

# Unsupported agent frontmatter fields.
invalid_agent_fields=$(
  grep -rn "^color:" .claude/agents/*.md 2>/dev/null || true
)
if [[ -n "${invalid_agent_fields}" ]]; then
  fail "unsupported subagent frontmatter fields remain:\n${invalid_agent_fields}"
fi

# Legacy slash-command names without aidd- prefix.
legacy_commands=$(
  grep -rn -E "/(new-ticket|new-phase|start-phase|run-checks|complete-phase|ship-feature|validate)\b" \
    AGENTS.md \
    CLAUDE.md \
    docs/README.md \
    docs/project/workflow.md \
    2>/dev/null || true
)
if [[ -n "${legacy_commands}" ]]; then
  fail "legacy slash command names remain:\n${legacy_commands}"
fi

# ---------------------------------------------------------------------------
# 6. Active feature docs (warnings)
# Per-ticket sanity checks against the v3 metadata contract and gate
# progression discipline.
# ---------------------------------------------------------------------------

if find docs -maxdepth 2 -name ".active_ticket" 2>/dev/null | grep -q .; then
  while IFS= read -r active_ticket; do
    ticket_root="$(dirname "${active_ticket}")"
    ticket_id="$(cat "${active_ticket}" | tr -d '[:space:]')"
    idea_path="${ticket_root}/idea-${ticket_id}.md"
    if [[ -f "${idea_path}" ]]; then
      if ! grep -qE "^Lane:" "${idea_path}" 2>/dev/null; then
        warn "feature doc without Lane header: ${idea_path}"
      fi
      if ! grep -qE "^Workflow Version:" "${idea_path}" 2>/dev/null; then
        warn "feature doc without Workflow Version header: ${idea_path}"
      elif ! grep -qE "^Workflow Version: 3$" "${idea_path}" 2>/dev/null; then
        warn "feature doc still on older workflow version: ${idea_path}"
      fi
      if ! grep -qE "^Status:" "${idea_path}" 2>/dev/null; then
        warn "idea without Status header: ${idea_path}"
      fi
    fi

    # Phase brief discipline: TASKLIST_READY with 0 checked tasks signals
    # a stub mistakenly advanced to TASKLIST_READY.
    phase_dir="${ticket_root}/phase/${ticket_id}"
    if [[ -d "${phase_dir}" ]]; then
      for brief in "${phase_dir}"/*.md; do
        [[ -f "${brief}" ]] || continue
        if grep -qE "^Status:.*TASKLIST_READY" "${brief}" 2>/dev/null; then
          checked=$(grep -cE '^\s*- \[x\]' "${brief}" 2>/dev/null || echo 0)
          if [[ "${checked}" -eq 0 ]]; then
            warn "phase brief TASKLIST_READY with 0 checked tasks: ${brief}"
          fi
        fi
      done
    fi
  done < <(find docs -maxdepth 2 -name ".active_ticket" 2>/dev/null | sort)
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo
echo "AIDD validation summary"
echo "failures: ${failures}"
echo "warnings: ${warnings}"

if [[ "${failures}" -gt 0 ]]; then
  exit 1
fi
