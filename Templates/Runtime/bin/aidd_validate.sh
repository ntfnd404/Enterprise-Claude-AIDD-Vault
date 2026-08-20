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

tier=$(
  awk -F '`' '/^- Tier: `[^`]+`$/ { print $2; exit }' CLAUDE.md 2>/dev/null \
    || true
)
case "${tier}" in
  lite|standard|enterprise) ;;
  *)
    echo "FAIL: CLAUDE.md must declare Tier as lite, standard, or enterprise"
    exit 1
    ;;
esac

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

normalize_id_set() {
  sed '/^$/d' | sort -u
}

report_set_difference() {
  local label="$1"
  local expected="$2"
  local actual="$3"
  local missing
  local extra

  missing=$(
    comm -23 \
      <(printf '%s\n' "${expected}" | normalize_id_set) \
      <(printf '%s\n' "${actual}" | normalize_id_set) \
      || true
  )
  extra=$(
    comm -13 \
      <(printf '%s\n' "${expected}" | normalize_id_set) \
      <(printf '%s\n' "${actual}" | normalize_id_set) \
      || true
  )

  if [[ -n "${missing}" || -n "${extra}" ]]; then
    fail "${label} set mismatch; missing=[$(printf '%s' "${missing}" | paste -sd, -)] extra=[$(printf '%s' "${extra}" | paste -sd, -)]"
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
  "docs/archive/README.md"
)

base_hook_files=(
  ".claude/settings.json"
  ".claude/bin/aidd_validate.sh"
  ".claude/hooks/instructions-loaded.sh"
  ".claude/hooks/session-compact.sh"
  ".claude/hooks/pre-edit-guard.sh"
  ".claude/hooks/post-compact-reinject.sh"
  ".claude/hooks/config-change-guard.sh"
  ".claude/hooks/file-changed-guard.sh"
)

base_agent_files=(
  ".claude/agents/analyst.md"
  ".claude/agents/planner.md"
  ".claude/agents/implementer.md"
  ".claude/agents/reviewer.md"
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
  "docs/project/templates/phase_review.md"
  "docs/project/templates/phase_qa.md"
  "docs/project/templates/phase_security_review.md"
  "docs/project/templates/trivial_tasklist.md"
  "docs/project/templates/trivial_review.md"
)

extra_template_files=(
  "docs/project/templates/adr.md"
)

base_workflow_skill_names=(
  "aidd-new-ticket"
  "aidd-start-phase"
  "aidd-diagnose-failure"
  "aidd-run-checks"
  "aidd-ship-feature"
  "aidd-init"
)

hook_files=("${base_hook_files[@]}")
agent_files=("${base_agent_files[@]}")
workflow_skill_names=("${base_workflow_skill_names[@]}")

if [[ "${tier}" != "lite" ]]; then
  hook_files+=(".claude/hooks/subagent-lifecycle.sh")
  agent_files+=(
    ".claude/agents/researcher.md"
    ".claude/agents/security-reviewer.md"
  )
  workflow_skill_names+=(
    "aidd-new-phase"
    "aidd-complete-phase"
    "aidd-validate"
  )
fi

if [[ "${tier}" == "enterprise" ]]; then
  hook_files+=(".claude/hooks/team-task-lifecycle.sh")
fi

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
    grep -nE '\]\([^)]*((docs/)?archive|docs|\.\./archive|\.\.)/[A-Z][A-Z0-9]*-[0-9]+/' "${roadmap_path}" \
      || true
  )
  if [[ -n "${ticket_workspace_links}" ]]; then
    fail "roadmap links directly to active or archived ticket workspaces:\n${ticket_workspace_links}"
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
# 2a. Completed-ticket archive contract
# ---------------------------------------------------------------------------

archive_root="docs/archive"
archive_index="${archive_root}/README.md"

if [[ -d "${archive_root}" && -f "${roadmap_path}" && -f "${archive_index}" ]]; then
  completed_ticket_ids=$(
    awk '
      /^## Completed tickets$/ { in_completed = 1; next }
      /^## / && in_completed { exit }
      in_completed && /^- [A-Z][A-Z0-9]*-[0-9]+([^0-9]|$)/ {
        line = $0
        sub(/^- /, "", line)
        sub(/[^A-Z0-9-].*$/, "", line)
        print line
      }
    ' "${roadmap_path}" | sort
  )

  archive_ticket_ids=$(
    find "${archive_root}" -mindepth 1 -maxdepth 1 -type d -print \
      | sed 's#^.*/##' \
      | sort
  )

  invalid_archive_ids=$(
    printf '%s\n' "${archive_ticket_ids}" \
      | sed '/^$/d' \
      | grep -Ev '^[A-Z][A-Z0-9]*-[0-9]+$' \
      || true
  )
  if [[ -n "${invalid_archive_ids}" ]]; then
    fail "invalid archive ticket directories: ${invalid_archive_ids}"
  fi

  archive_index_ids=$(
    grep -E '^\| [A-Z][A-Z0-9]*-[0-9]+ \|' "${archive_index}" \
      | sed -E 's/^\| ([A-Z][A-Z0-9]*-[0-9]+) \|.*/\1/' \
      | sort \
      || true
  )
  duplicate_archive_index_ids=$(
    printf '%s\n' "${archive_index_ids}" \
      | sed '/^$/d' \
      | uniq -d \
      || true
  )
  if [[ -n "${duplicate_archive_index_ids}" ]]; then
    fail "archive index contains duplicate ticket IDs: ${duplicate_archive_index_ids}"
  fi

  report_set_difference \
    "completed roadmap/archive directory" \
    "${completed_ticket_ids}" \
    "${archive_ticket_ids}"
  report_set_difference \
    "completed roadmap/archive index" \
    "${completed_ticket_ids}" \
    "${archive_index_ids}"

  archive_markers=$(find "${archive_root}" -name ".active_ticket" -print || true)
  if [[ -n "${archive_markers}" ]]; then
    fail "active ticket markers found inside archive:\n${archive_markers}"
  fi

  duplicate_lifecycle_ids=""
  while IFS= read -r archive_ticket_id; do
    [[ -n "${archive_ticket_id}" ]] || continue
    if [[ -d "docs/${archive_ticket_id}" ]]; then
      duplicate_lifecycle_ids="${duplicate_lifecycle_ids}${archive_ticket_id}"$'\n'
    fi
  done <<< "${archive_ticket_ids}"
  duplicate_lifecycle_ids=$(printf '%s' "${duplicate_lifecycle_ids}" | sed '/^$/d')
  if [[ -n "${duplicate_lifecycle_ids}" ]]; then
    fail "ticket IDs exist in both active and archived locations: ${duplicate_lifecycle_ids}"
  fi
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
)

if [[ "${tier}" != "lite" ]]; then
  hook_events+=("SubagentStart" "SubagentStop")
fi

if [[ "${tier}" == "enterprise" ]]; then
  hook_events+=("TaskCreated" "TaskCompleted" "TeammateIdle")
fi

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

    # Release-ready evidence is lane-aware. Trivial tickets use one
    # ticket-level review; phase-based lanes retain exact phase coverage.
    # Ordinary unfinished tickets are intentionally not subject to this gate.
    tasklist_path="${ticket_root}/tasklist-${ticket_id}.md"
    if [[ -f "${tasklist_path}" ]] \
      && grep -qE '^Status: `?(RELEASE_READY|DOCS_UPDATED)`?$' "${tasklist_path}" 2>/dev/null; then
      ticket_lane=""
      if [[ -f "${idea_path}" ]]; then
        ticket_lane=$(awk -F ': ' '/^Lane: / { print $2; exit }' "${idea_path}")
      fi

      if [[ "${ticket_lane}" == "Trivial" ]]; then
        trivial_review_dir="${ticket_root}/review"
        trivial_review_path="${trivial_review_dir}/${ticket_id}-review.md"
        trivial_review_candidates=$(
          find "${trivial_review_dir}" -maxdepth 1 -type f \
            -name "${ticket_id}-review*.md" -print 2>/dev/null \
            | sort \
            || true
        )
        trivial_review_count=$(
          printf '%s\n' "${trivial_review_candidates}" \
            | sed '/^$/d' \
            | wc -l \
            | tr -d '[:space:]'
        )

        if [[ "${trivial_review_count}" -ne 1 ]]; then
          fail "release-ready Trivial ticket must have exactly one ticket-level review: ${ticket_id}; found=${trivial_review_count}"
        fi
        trivial_unexpected_reviews=$(
          find "${trivial_review_dir}" -maxdepth 1 -type f \
            ! -name "${ticket_id}-review.md" -print 2>/dev/null \
            | sort \
            || true
        )
        if [[ -n "${trivial_unexpected_reviews}" ]]; then
          fail "release-ready Trivial ticket has non-canonical review files: ${ticket_id}"
        fi
        if [[ ! -f "${trivial_review_path}" ]]; then
          fail "release-ready Trivial ticket is missing review: ${trivial_review_path}"
        else
          if ! grep -qE '^Status: `?REVIEW_OK`?$' "${trivial_review_path}" 2>/dev/null; then
            fail "release-ready Trivial review is not REVIEW_OK: ${trivial_review_path}"
          fi
          if ! grep -qE "^Ticket: ${ticket_id}$" "${trivial_review_path}" 2>/dev/null; then
            fail "release-ready Trivial review has mismatched Ticket metadata: ${trivial_review_path}"
          fi
          if ! grep -qE '^Lane: Trivial$' "${trivial_review_path}" 2>/dev/null; then
            fail "release-ready Trivial review has mismatched Lane metadata: ${trivial_review_path}"
          fi
          if ! awk '
            /^## Verdict$/ { in_verdict = 1; next }
            /^## / && in_verdict { exit }
            in_verdict && /^`REVIEW_OK`$/ { found = 1 }
            END { exit(found ? 0 : 1) }
          ' "${trivial_review_path}"; then
            fail "release-ready Trivial review verdict is not REVIEW_OK: ${trivial_review_path}"
          fi
        fi

        trivial_scaffold_evidence=""
        for trivial_scaffold_dir in phase plan prd research qa security; do
          if [[ -d "${ticket_root}/${trivial_scaffold_dir}" ]]; then
            trivial_scaffold_files=$(
              find "${ticket_root}/${trivial_scaffold_dir}" -type f -print 2>/dev/null \
                | sort \
                || true
            )
            trivial_scaffold_evidence="${trivial_scaffold_evidence}${trivial_scaffold_files}"
          fi
        done
        trivial_phase_reviews=$(
          find "${trivial_review_dir}" -maxdepth 1 -type f \
            -name "${ticket_id}-phase-*-review.md" -print 2>/dev/null \
            | sort \
            || true
        )
        trivial_vision_evidence=""
        if [[ -f "${ticket_root}/vision-${ticket_id}.md" ]]; then
          trivial_vision_evidence="${ticket_root}/vision-${ticket_id}.md"
        fi
        if [[ -n "${trivial_scaffold_evidence}${trivial_phase_reviews}${trivial_vision_evidence}" ]]; then
          fail "release-ready Trivial ticket contains phase, plan, PRD, research, vision, QA, or security evidence: ${ticket_id}"
        fi
      else
        phase_dir="${ticket_root}/phase"
        unexpected_phase_artifacts=""
        for artifact_rule in \
          "phase|${ticket_id}-phase-*-brief.md" \
          "plan|${ticket_id}-phase-*-plan.md" \
          "prd|${ticket_id}-phase-*-prd.md" \
          "research|${ticket_id}-phase-*-research.md" \
          "review|${ticket_id}-phase-*-review.md" \
          "qa|${ticket_id}-phase-*-qa.md" \
          "security|${ticket_id}-phase-*-security.md"; do
          artifact_dir=${artifact_rule%%|*}
          artifact_pattern=${artifact_rule#*|}
          unexpected_files=$(
            find "${ticket_root}/${artifact_dir}" -maxdepth 1 -type f \
              ! -name "${artifact_pattern}" -print 2>/dev/null \
              | sort \
              || true
          )
          if [[ -n "${unexpected_files}" ]]; then
            unexpected_phase_artifacts="${unexpected_phase_artifacts}${unexpected_files}"$'\n'
          fi
        done
        if [[ -n "${unexpected_phase_artifacts}" ]]; then
          fail "release-ready ticket contains non-canonical phase artifact filenames: ${ticket_id}"
        fi

        declared_phase_ids=$(
          find "${phase_dir}" -maxdepth 1 -type f -name "${ticket_id}-phase-*-brief.md" -print 2>/dev/null \
            | sed -E 's#^.*/[^/]+-phase-([0-9]+)-brief[.]md$#\1#' \
            | sort -n
        )
        if [[ -z "${declared_phase_ids}" ]]; then
          fail "release-ready ticket has no declared phase briefs: ${ticket_id}"
        fi

        review_phase_ids=$(
          find "${ticket_root}/review" -maxdepth 1 -type f \
            -name "${ticket_id}-phase-*-review.md" -print 2>/dev/null \
            | sed -E 's#^.*/[^/]+-phase-([0-9]+)-review[.]md$#\1#' \
            | sort -n
        )
        qa_phase_ids=$(
          find "${ticket_root}/qa" -maxdepth 1 -type f \
            -name "${ticket_id}-phase-*-qa.md" -print 2>/dev/null \
            | sed -E 's#^.*/[^/]+-phase-([0-9]+)-qa[.]md$#\1#' \
            | sort -n
        )

        plan_phase_ids=$(
          find "${ticket_root}/plan" -maxdepth 1 -type f \
            -name "${ticket_id}-phase-*-plan.md" -print 2>/dev/null \
            | sed -E 's#^.*/[^/]+-phase-([0-9]+)-plan[.]md$#\1#' \
            | sort -n
        )
        prd_phase_ids=$(
          find "${ticket_root}/prd" -maxdepth 1 -type f \
            -name "${ticket_id}-phase-*-prd.md" -print 2>/dev/null \
            | sed -E 's#^.*/[^/]+-phase-([0-9]+)-prd[.]md$#\1#' \
            | sort -n
        )
        research_phase_ids=$(
          find "${ticket_root}/research" -maxdepth 1 -type f \
            -name "${ticket_id}-phase-*-research.md" -print 2>/dev/null \
            | sed -E 's#^.*/[^/]+-phase-([0-9]+)-research[.]md$#\1#' \
            | sort -n
        )

        critical_phase_ids=""
        if [[ -d "${phase_dir}" ]]; then
          while IFS= read -r phase_brief; do
            [[ -f "${phase_brief}" ]] || continue
            if grep -qE '^Lane: Critical$' "${phase_brief}" 2>/dev/null; then
              phase_number=$(basename "${phase_brief}" | sed -E 's/^.*-phase-([0-9]+)-brief[.]md$/\1/')
              critical_phase_ids="${critical_phase_ids}${phase_number}"$'\n'
            fi
          done < <(find "${phase_dir}" -maxdepth 1 -type f -name "${ticket_id}-phase-*-brief.md" -print 2>/dev/null | sort)
        fi
        critical_phase_ids=$(printf '%s' "${critical_phase_ids}" | sed '/^$/d' | sort -n)
        security_phase_ids=$(
          find "${ticket_root}/security" -maxdepth 1 -type f \
            -name "${ticket_id}-phase-*-security.md" -print 2>/dev/null \
            | sed -E 's#^.*/[^/]+-phase-([0-9]+)-security[.]md$#\1#' \
            | sort -n
        )

        report_set_difference \
          "${ticket_id} release-ready plan phases" \
          "${declared_phase_ids}" \
          "${plan_phase_ids}"
        report_set_difference \
          "${ticket_id} release-ready PRD phases" \
          "${declared_phase_ids}" \
          "${prd_phase_ids}"
        report_set_difference \
          "${ticket_id} release-ready research phases" \
          "${declared_phase_ids}" \
          "${research_phase_ids}"

        report_set_difference \
          "${ticket_id} release-ready review phases" \
          "${declared_phase_ids}" \
          "${review_phase_ids}"
        report_set_difference \
          "${ticket_id} release-ready QA phases" \
          "${declared_phase_ids}" \
          "${qa_phase_ids}"
        report_set_difference \
          "${ticket_id} release-ready Critical security phases" \
          "${critical_phase_ids}" \
          "${security_phase_ids}"
      fi
    fi

    # Phase brief discipline: TASKLIST_READY with 0 checked tasks signals
    # a stub mistakenly advanced to TASKLIST_READY.
    nested_phase_dir="${ticket_root}/phase/${ticket_id}"
    if [[ -d "${nested_phase_dir}" ]] \
      && find "${nested_phase_dir}" -type f -print -quit 2>/dev/null | grep -q .; then
      fail "active ticket uses redundant nested phase directory; expected docs/${ticket_id}/phase/${ticket_id}-phase-N-brief.md: ${ticket_id}"
    fi

    phase_dir="${ticket_root}/phase"
    if [[ -d "${phase_dir}" ]]; then
      for brief in "${phase_dir}/${ticket_id}"-phase-*-brief.md; do
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
