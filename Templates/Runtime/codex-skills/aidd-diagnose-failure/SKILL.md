---
name: aidd-diagnose-failure
description: Diagnose an AIDD QA_FAIL, flaky test, runtime bug, or unexplained check failure before proposing a fix. Do not use for an expected TDD red test or an obvious local syntax error.
allowed-tools: Read Glob Grep Bash
---

# AIDD Diagnose Failure for Codex

Resolve the containing skill directory to its physical target inside the AIDD
Vault, following either a directory or file symlink. Then read the canonical
workflow completely from this path relative to that physical directory:

`../../skills/aidd-diagnose-failure--SKILL.md`

Ignore its Claude-specific YAML frontmatter and follow its Markdown protocol.
That file is the single source of truth for diagnostic behavior. Preserve its
read-only boundary and all owner-approval, routing, evidence, and stop
conditions.

If the canonical file is unavailable, stop and report the missing path instead
of reconstructing the workflow from memory.
