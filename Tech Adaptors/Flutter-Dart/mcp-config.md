# Flutter-Dart MCP Configuration

## `.mcp.json`

```json
{
  "mcpServers": {
    "dart": {
      "command": "dart",
      "args": ["mcp-server"]
    }
  }
}
```

## Available MCP Tools

| Tool | Purpose | Used By |
|---|---|---|
| `mcp__dart__analyze_files` | Static analysis | `/aidd-run-checks` |
| `mcp__dart__dart_format` | Code formatting (supports `paths` param) | `/aidd-run-checks`, PostToolUse hook |
| `mcp__dart__run_tests` | Test execution | `/aidd-run-checks` |
| `mcp__dart__pub` | Dependency management | Manual |
| `mcp__dart__pub_dev_search` | Package search | Manual |
| `mcp__dart__hover` | Symbol information | Research |
| `mcp__dart__resolve_workspace_symbol` | Symbol lookup | Research |
| `mcp__dart__launch_app` | Launch app for debugging | Manual |
| `mcp__dart__hot_reload` | Hot reload running app | Manual |
| `mcp__dart__hot_restart` | Hot restart running app | Manual |

## MCP-First Strategy

For deterministic operations, prefer MCP tools over Bash commands:

1. **Format**: `mcp__dart__dart_format` with `paths` parameter (changed files only)
2. **Analyze**: `mcp__dart__analyze_files`
3. **Test**: `mcp__dart__run_tests`

Fall back to CLI commands when MCP is unavailable.

## Limitations

- MCP `analyze_files` does NOT run DCM rules — use `metrics analyze` CLI separately
- MCP format uses `paths` param for targeted formatting — more efficient than formatting everything
- MCP tools are deterministic — do not use for architecture or review reasoning

## Verification

```text
/mcp
```

Should show `dart` server with available tools.
