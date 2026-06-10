# Flutter-Dart MCP Configuration

## `.mcp.json`

```json
{
  "mcpServers": {
    "dart": {
      "command": "dart",
      "args": ["mcp-server"]
    },
    "dcm": {
      "command": "dcm",
      "args": ["start-mcp-server", "--client=claude-desktop"]
    }
  }
}
```

## Available MCP Tools

### Dart MCP (`dart mcp-server`)

| Tool | Purpose | Used By |
|---|---|---|
| `mcp__dart__analyze_files` | Static analysis (Dart analyzer) | `/aidd-run-checks` |
| `mcp__dart__dart_format` | Code formatting (supports `paths` param) | `/aidd-run-checks`, PostToolUse hook |
| `mcp__dart__run_tests` | Test execution | `/aidd-run-checks` |
| `mcp__dart__pub` | Dependency management | Manual |
| `mcp__dart__pub_dev_search` | Package search | Manual |
| `mcp__dart__hover` | Symbol information | Research |
| `mcp__dart__resolve_workspace_symbol` | Symbol lookup | Research |
| `mcp__dart__launch_app` | Launch app for debugging | Manual |
| `mcp__dart__hot_reload` | Hot reload running app | Manual |
| `mcp__dart__hot_restart` | Hot restart running app | Manual |

### DCM MCP (`dcm mcp-server`)

| Tool | Purpose | Used By |
|---|---|---|
| `mcp__dcm__analyze` | DCM rules + metrics analysis (requires DCM licence) | `/aidd-run-checks` |
| `mcp__dcm__fix` | Auto-fix DCM issues | Manual |

## MCP-First Strategy

For deterministic operations, prefer MCP tools over Bash commands:

1. **Format**: `mcp__dart__dart_format` with `paths` parameter (changed files only)
2. **Analyze (Dart)**: `mcp__dart__analyze_files`
3. **Analyze (DCM)**: `mcp__dcm__analyze` (falls back to `dcm analyze` CLI if MCP unavailable)
4. **Test**: `mcp__dart__run_tests`

Fall back to CLI commands when MCP is unavailable.

## Limitations

- `mcp__dart__analyze_files` does NOT run DCM rules — use `mcp__dcm__analyze` or `dcm analyze` CLI
- MCP format uses `paths` param for targeted formatting — more efficient than formatting everything
- MCP tools are deterministic — do not use for architecture or review reasoning
- DCM MCP requires a valid DCM licence (`dcm login` before first use)

## Verification

```text
/mcp
```

Should show both `dart` and `dcm` servers with available tools.
