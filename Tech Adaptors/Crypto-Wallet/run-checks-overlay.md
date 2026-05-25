# Crypto-Wallet Run Checks Overlay

This is a **domain adaptor** — it does not add format / analyze / lint tooling. The check pipeline (`format` → `analyze` → `lint` → `test`) is defined by the chosen tech-stack adaptor.

The rules below describe **what the test step must cover** when the Crypto-Wallet adaptor is applied. They are appended to the stack adaptor's pipeline as additional acceptance criteria — not as separate pipeline steps.

---

## Required Test Coverage

The crypto layer is a hard-failure surface. Bugs are silent and can lose funds. The test step must satisfy all of the following before a phase passes:

### 1. Reference Vector Tests

- Every deterministic primitive used by the wallet (mnemonic generation / parsing, seed derivation, key derivation, address encoding, signing scheme) must be tested against published reference vectors from the relevant standards body.
- Vector files live under `test/vectors/` (or stack-idiomatic equivalent) and are version-controlled.
- A failing vector test is a release blocker — no exceptions, no `skip`.

### 2. Boundary Tests

For each public method of the key-derivation / signing layer:

- **Happy path** with a fixed test seed
- **Invalid input** — malformed mnemonic, wrong-length seed, out-of-range derivation index — must raise the correct sanitized domain error
- **Boundary index** — first / last valid derivation index, hardened vs non-hardened
- **Determinism** — calling the same method twice with the same input returns byte-identical output

### 3. Leak Tests

- Error messages thrown across the key-layer boundary must not contain mnemonic words, seed bytes, or private key material. Add an assertion test for at least one representative error per category.
- Where the project ships a logger or analytics SDK: assert the redaction filter strips known sensitive field names.

### 4. Network Isolation

- Crypto-layer unit tests must run **fully offline**. Any test that requires a network endpoint belongs in an integration suite, not the unit test step.
- Integration tests against a local devnet / testnet / local-node endpoint are allowed; they must never connect to mainnet, and must reject mainnet endpoints if invoked with mainnet keys.

---

## Acceptance Criteria for `/aidd-run-checks`

The stack adaptor's `aidd-checks.sh` must pass. **Additionally**, when this adaptor is applied:

- The reference-vector test files referenced above must exist and be picked up by the stack adaptor's test runner.
- A coverage report (if the stack supports it) must show **100% line + branch coverage** for files inside the key-derivation / signing layer. Files outside that layer are subject to the project's normal coverage targets.
- No test in the crypto layer may be marked `skip` or `solo` / `focused` in committed code.

---

## Recommended Hooks

The phase-level QA gate (`qa.md` agent) for any Critical-lane phase that touches the key layer must explicitly verify:

- Reference vectors run and pass
- Leak tests run and pass
- No mainnet endpoints in code or fixtures

These are checks the human + QA agent perform on top of the automated pipeline — they are not currently scriptable.
