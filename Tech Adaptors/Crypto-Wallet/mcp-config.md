# Crypto-Wallet MCP Configuration

This is a **domain adaptor** — it does not ship its own MCP server. The MCP configuration of the project is owned by the chosen tech-stack adaptor (e.g., `Flutter-Dart/mcp-config.md`).

When applying both a stack adaptor and `Crypto-Wallet`:

1. The stack adaptor's `mcp-config.md` is the only source of `.mcp.json`
2. `Crypto-Wallet` does not add, remove, or modify MCP server entries
3. No additional `mcp__*` tools are introduced by this adaptor

---

## Why no MCP server here

The crypto-wallet domain has no widely available MCP server today. Domain logic — derivation, signing, address encoding — is verified through:

- Reference vector tests (see `run-checks-overlay.md`)
- The stack adaptor's analyze / lint / test pipeline
- Manual code review by the `reviewer` and `security-reviewer` agents

If a chain-specific MCP server later becomes useful (block explorer queries, fee estimation, mempool inspection), it can be added in this file as an optional supplementary entry — but it must not replace or override the stack adaptor's MCP configuration.

---

## Verification

After applying both adaptors:

```text
/mcp
```

Should show only the servers declared by the stack adaptor. If anything else appears, investigate before continuing.
