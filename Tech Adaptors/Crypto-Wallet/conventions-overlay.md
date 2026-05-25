# Crypto-Wallet Conventions Overlay

These rules are appended to `docs/project/conventions.md` when the Crypto-Wallet domain adaptor is applied. This is a **domain adaptor** — it combines with a tech-stack adaptor (e.g., Flutter-Dart, Kotlin-Android, Swift-iOS).

Scope: any application that holds, derives, or uses key material for cryptocurrency wallets — regardless of chain, network, or implementation language.

---

## Wallet Types and Trust Model

A wallet implementation is one of two trust models, and the model must be explicit for every flow:

| Type | Owns Keys | Notes |
|------|-----------|-------|
| **Custodial / Node** | External system (node, exchange, custodian) | App is a UI over a remote API; never sees private material |
| **Non-Custodial / HD** | Application | App owns mnemonic + derivation; key material never leaves the device unencrypted |

Every wallet entity must carry its trust type. Flows must branch on type rather than assuming one model.

---

## Layer Boundaries for Key Material

Key material must be confined to a single dedicated layer. The rest of the app sees only opaque handles, addresses, and signed payloads.

| Layer | What it sees | What it never sees |
|-------|--------------|--------------------|
| **Key derivation** (e.g., `keys/`, `crypto/` package) | Mnemonic, seed, master key, derived private keys | UI state, network results |
| **Signing** (within key layer or adjacent) | Private key (transient), unsigned payload | Anything else |
| **Data / Repository** | Public keys, addresses, signed payloads, opaque key handles | Private keys, mnemonic, seed |
| **Domain / Application** | Addresses, signed payloads, public metadata | Private keys, mnemonic, seed |
| **Presentation / UI** | Addresses, balances, status | Private keys, mnemonic, seed |

The key derivation layer **is the only place** that ever materialises a private key in memory. It must:

- Expose only signing operations and public derivations as its public API
- Zero out / drop key material as soon as the operation completes
- Never return a private key, mnemonic, or seed to a caller

---

## Storage Rules

- Mnemonic, seed, and any persisted private material must be stored **only** in platform secure storage (Keychain, Keystore, EncryptedSharedPreferences, equivalent). Never plain files, never SharedPreferences/UserDefaults, never SQLite without an encrypted column, never local logs.
- The secure-storage handle must be wrapped behind a domain-level interface (e.g., `SeedRepository`, `KeyVault`) so call sites never touch the platform API directly.
- Backup / export flows must be opt-in, behind explicit user confirmation, and must never leave material in temporary files, clipboard buffers without TTL, or sync directories.

---

## Network Rules

- Private key material must **never** appear on the wire. Signing happens locally; only signed payloads are transmitted.
- For watch-only / xpub flows: only public keys and addresses are sent to remote services.
- HTTPS is mandatory for any remote endpoint that handles wallet data, including watch-only metadata.
- Local development against testnet / devnet / local-node endpoints is allowed; production code paths must reject non-production endpoints when running against mainnet keys (and vice versa).

---

## Error Handling

Errors involving cryptographic operations must not leak state about the underlying secret. In particular:

- Error messages must not include key material, mnemonic words, derivation paths that uniquely identify a key, or signature components.
- Error types raised across the key-layer boundary must be sanitized — wrap raw library exceptions in domain errors that carry only the failure category (e.g., `InvalidMnemonic`, `DerivationFailed`, `SigningFailed`), never the offending input.
- Crash reporters, analytics SDKs, and telemetry channels must be configured to exclude any field that could carry key material. When in doubt, redact.

---

## Determinism and Test Vectors

- All deterministic primitives (BIP-style derivation, signing schemes with deterministic nonces, address encoding) must be unit-tested against published reference vectors.
- Production code must use library implementations of standardised algorithms (e.g., RFC 6979 for ECDSA nonces) — never a hand-rolled nonce or PRNG seed.
- Tests must run against fixed test vectors only — never against live mainnet data.

---

## Hard Rules (Never Violate)

```
Never log or expose mnemonic, seed, or private key material in UI, logs, error messages, exceptions, telemetry, analytics, or crash reports
Never expose a private key outside the dedicated key-derivation / signing layer — return signed payloads instead
Never serialise private key material to plaintext storage — use platform secure storage only
Never use mainnet / production keys or real funds in development, CI, or test environments
Never derive or sign outside the dedicated key layer — no parallel implementations in feature code
Never reuse a one-time nonce, derivation index intended as one-shot, or ephemeral key
Never accept a mnemonic, seed, or private key as input from an untrusted channel (deep link, paste from unfocused app, URL parameter) without explicit user confirmation
Never copy mnemonic or seed to the system clipboard without an automatic clear after a short TTL
Never transmit private key material over the network — sign locally, send signed payload
Never include key material in error messages thrown across the key-layer boundary — wrap and sanitize
Never roll your own crypto — use vetted library implementations of standardised algorithms
Never mix mainnet and testnet keys in the same storage namespace
```

---

## Combination With Tech-Stack Adaptors

This adaptor only adds domain rules. Architectural patterns (DI style, state management, package layout) come from the chosen tech-stack adaptor. When both apply, the strictest rule wins — for example, if the stack adaptor requires constructor DI and this adaptor requires the key layer to be accessible only via a `KeyVault` interface, both must hold simultaneously.
