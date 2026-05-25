# Crypto-Wallet Code Style Overlay

These rules are appended to `docs/project/code-style-guide.md` when the Crypto-Wallet domain adaptor is applied.

This is a **domain adaptor** — formatting, naming conventions, member ordering, and import organisation come from the chosen tech-stack adaptor (Flutter-Dart, Kotlin-Android, Swift-iOS, etc.). The rules below are **on top of** the stack adaptor and apply only to crypto-domain code.

---

## Naming for Sensitive Types

To make sensitive material visible at a glance during review:

- Types that hold or transit private key material, mnemonic words, or seed bytes should carry a `Sensitive` or `Secret` suffix in the name (or an equivalent stack-idiomatic marker — e.g., `SeedSensitive`, `PrivateKeySecret`).
- Methods that return such material must carry the same marker in their return type.
- Public APIs of the key layer should expose only sanitized types (`PublicKey`, `Address`, `SignedPayload`) — `Sensitive`/`Secret` types should be confined to the key layer's internals.

This is a review aid, not a security control. The actual control is the layer boundary.

---

## Trust-Boundary Comments

When a function crosses a trust boundary — handing key material to a signer, persisting a seed to secure storage, releasing a signed payload to the network layer — mark the call site with an explicit comment:

```
// SECURITY: <one-line description of the boundary being crossed>
```

The comment must state what is crossing the boundary and why. This makes security-relevant flows greppable and forces the author to articulate the boundary.

Examples:

```
// SECURITY: seed leaves SeedRepository to the deriver; deriver must drop it after use.
// SECURITY: persisting wrapped private key to platform secure storage; never plaintext.
// SECURITY: signed payload leaves the key layer; no private material in this object.
```

Do **not** scatter these comments through ordinary code — only on actual boundary crossings. Overuse dilutes their signal.

---

## Test Vector Files

- Reference test vectors (BIP, RFC, IETF, chain-spec) must live under a clearly named `test/vectors/` (or stack-idiomatic equivalent) directory and be checked into the repository.
- Each vector file must carry a header comment naming its source (spec name + version + URL) and the date of import.
- Vector files are **input data**, not code — they must not be edited to make tests pass; if a vector mismatches, the implementation is wrong.

---

## Logging

- The crypto layer must use a logger that is configured to drop or redact fields tagged sensitive — or it must not log them at all.
- Log levels for the crypto layer should be conservative: errors are categories (`SigningFailed`), not stack-trace dumps that may include offending input.
- Production builds must strip debug-level crypto logs entirely — they should not be controllable by a runtime flag.
