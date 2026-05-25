# Flutter-Dart Conventions Overlay

These rules are appended to `docs/project/conventions.md` when the Flutter-Dart adaptor is applied.

---

## Architecture: Clean Architecture + Hexagonal

```
lib/                    → Presentation (Flutter UI + BLoC)
packages/domain/        → Domain (entities + interfaces, ZERO deps)
packages/data/          → Data (repository + service implementations)
packages/<infra>/       → Infrastructure (wraps one external system each)
packages/ui_kit/        → UI: Design system (tokens, typography, theme)
```

### Dependency Graph

```
data      → domain, <infra packages>
ui_kit    → Flutter SDK (only)
<infra>   → external library (only)
domain    → (nothing)
```

### Package Type Rules

| Type | Rule |
|------|------|
| **core** (`domain`) | Entities + interfaces. Pure Dart. Zero dependencies. |
| **core** (`data`) | Implements domain. Orchestrates infra adapters. |
| **infra** | Wraps one external system. No domain knowledge. |
| **ui** (`ui_kit`) | Design system only. No domain knowledge. |

---

## Architecture Patterns

### Strategy over `switch` on type

When a use case branches by entity type or wallet type, register a **Strategy** per type instead of `switch(entity.type)`. Each strategy declares which type it supports; the use case asks the registry.

```dart
// ❌ Closed for extension
class SignTransactionUseCase {
  Future<String> call(Transaction tx) {
    switch (tx.kind) {
      case TxKind.p2pkh: ...
      case TxKind.p2wpkh: ...
    }
  }
}

// ✅ Strategy registry — adding a new kind doesn't touch the use case
abstract interface class SigningStrategy {
  bool supports(TxKind kind);
  Future<String> sign(Transaction tx);
}
```

OCP: adding a new kind = adding a new strategy, never editing the use case.

### Gateway interfaces belong in `domain/` (DIP)

The high-level module declares the contract; the low-level module implements it.

- `XxxGateway` interface lives in `<consumer>/domain/gateway/`
- Implementation lives in the infra package (e.g. `bitcoin_node/`)
- Never put the gateway interface in the adapter package — that inverts DIP

### Thin use case rule

Do not create a use case that only delegates to a single repository or gateway method with no added logic. Call the repository/gateway directly. A use case is justified only when it:

- Orchestrates multiple calls, or
- Translates between bounded contexts, or
- Enforces a domain rule, or
- Handles scenario-specific exceptions

### ID generation lives in the Application layer

Generating an aggregate ID is a use-case responsibility, not a repository concern. Repositories receive a fully-formed entity. This keeps repositories CRUD-only.

---

## State Management: BLoC Only

- **BLoC only** — no Cubits (enforced by linter)
- Events: past-tense user actions (`WalletListRequested`, `ThemeChanged`)
- State: hand-written immutable class with enum `status`. **Default recommendation** is `@freezed` for state classes; **project may override** to hand-written classes (no codegen) — this is a common, valid override and adapter consumers must check their project conventions before adopting freezed.
- `abstract interface class` for interfaces; `Impl` suffix for implementations
- **Never** store mutable state in private BLoC fields — all state in the State class
- **Never** expose public fields or methods on BLoC — all logic via events
- Check `isClosed` before `emit()` after every async gap

---

## BLoC State Discipline

State carries **only persistent UI signals**. One-shot effects go to a separate Action stream.

### What belongs in `State`

- `status` enum (process phase)
- Data lists, currently-rendered values
- Typed nullable failure for **persistent** error rendering (`KeysException? failure`) — only when the error is meant to stay visible until the user acts

### What does NOT belong in `State`

- `Exception? exception` — never. A transient error is not state.
- `lastErrorMessage` — never. Same reason.
- Navigation triggers, focus requests, dialog flags — these are actions, not state.
- Inter-event scratch variables on the BLoC itself — they belong in `State` for hot-restart safety.

### Status enum standard

```dart
enum XxxStatus { idle, processing }
```

- Use `idle / processing / successful` — **never** `initial / loading / loaded`.
- **No `error` value** in the status enum. Errors are one-shot actions; status returns to `idle`.
- Wizard flows with meaningful intermediate steps (`scanning`, `signing`, `broadcasted`) may keep them — but still no `error` and no `initial / idle` redundancy.
- After every error: `emit(state.copyWith(status: XxxStatus.idle))` so the UI never gets stuck.

### Side-effect channels

Two distinct channels for effects outside `State`. The one-line distinction:

> **Action = "the feature talks to its own UI."**
> **EventBus = "the feature talks to another feature, without knowing which."**

| Channel | API | Direction | Coupling | Use when |
|---|---|---|---|---|
| **Action stream** | `emitAction(XxxAction(...))` + `ActionBlocListener` | BLoC → UI of the **same** feature | UI subtree listens directly | SnackBar, navigation, focus, clipboard, dialog |
| **Event bus** | `_eventBus.emit(XxxEvent(...))` in BLoC; `_eventBus.on<XxxEvent>().listen(...)` in another BLoC's constructor (unsubscribe in `close()`) | BLoC → **another BLoC**, cross-feature | Emitter does not know who subscribes; subscribers do not know who emits | Broadcast → refresh; cross-feature notifications |

Why both exist:
- **Action stream** keeps presentation effects *out of state* so widget rebuild does not retrigger SnackBars / navigation. Action is consumed once, then gone.
- **EventBus** keeps BLoCs *out of each other's import graph*. Even `BlocListener<OtherBloc, OtherState>` is forbidden across features — it couples presentation to a concrete BLoC and inverts the dependency direction. EventBus emits typed `sealed class AppEvent`, subscribers attach independently.

Rules:
- Never route UI effects (SnackBar, navigation) through the event bus — couples presentation to the bus and inverts dependency direction (presentation → domain becomes domain → presentation).
- Never route cross-feature notifications through `emitAction` — actions are scoped to one BLoC's widget subtree; another feature will never see them.
- Never use `BlocListener<OtherFeatureBloc, …>` across features — use EventBus.
- Broad `catch (e, stack)` in a BLoC handler **must** `emitAction(XxxUnexpectedFailedAction())` **before** `addError(e, stack)` — the user must see feedback even if the BLoC closes afterward.

### Action naming

All concrete action classes end with `Action`, symmetric with `Bloc / Event / State`. Example: `WalletErrorOccurredAction`, `SendFailedAction`.

---

## Layered Error Handling

Each layer handles only the errors that belong to its contract.

| Layer | Responsibility | Catch pattern |
|---|---|---|
| **Gateway / DataSource** | Translate external failures (RPC, network, parse) into bounded-context exceptions | `catch (_, stack)` + `Error.throwWithStackTrace(DomainException(), stack)` |
| **Use Case** | Catch only exceptions that are part of the use-case scenario (cross-BC translation, algorithm fallbacks, security sanitization) | **Selective** `on X catch` + `on Y { rethrow }` — no broad `catch (e, stack)` unless justified |
| **BLoC / Controller** | Catch bounded-context domain exceptions for UI feedback | `on XxxException catch (e) → emitAction`; unexpected → `addError` |
| **Domain Service** | Mostly no `try/catch`; only expected algorithm branches (e.g. `InsufficientFundsException` inside a coin-selection loop) | — |

### Selective catches in use cases

Broad `catch (e, stack)` in a use case **masks programmer errors** (TypeError, RangeError) as domain exceptions. Hides bugs from the zone handler.

```dart
// ❌ Hides bugs
try {
  return await _doWork();
} catch (e, stack) {
  Error.throwWithStackTrace(const SomeException(), stack);
}

// ✅ Selective — programmer errors propagate
try {
  return await _doWork();
} on KeysStorageException catch (_, stack) {
  Error.throwWithStackTrace(const WalletStorageException(), stack);
} on WalletException {
  rethrow;
}
```

If there is no language translation and no recovery — drop the `try/catch` entirely. Pure delegation is fine.

### Broad `catch` exception: security-first use cases

A use case may use broad `catch (_, stack)` **only** if all four criteria hold:

1. **Change abstraction** — translate internal vocabulary to domain language
2. **Hide secrets** — caught exception messages may carry sensitive material that must not leak
3. **Add context** — preserve original stack trace via `Error.throwWithStackTrace`
4. **Can recover** — caller can distinguish typed exceptions and act

Sign use cases over key material qualify. Generic delegation use cases do not.

### Typed exception at layer boundary — 4-criteria framework

A typed wrapper exception on a layer boundary is justified if **any one** holds:

| Criterion | Question |
|---|---|
| (a) Change abstraction | Does the wrapper translate vocabulary across BCs? |
| (b) Hide secrets | Could the underlying exception's message leak sensitive data? |
| (c) Add context | Is the wrap adding diagnostic information? |
| (d) Can recover | Can the caller distinguish typed wrappers and act differently? |

Do **not** dismiss the wrap because consumers currently do generic `catch (_)`. Consumer habits ≠ layer contract. The contract is what the layer **promises**, not what callers happen to use today.

### `rethrow` vs `Error.throwWithStackTrace`

- `rethrow` — re-throws the **same** exception object. Use when adding no translation.
- `Error.throwWithStackTrace(newException, stack)` — creates a **new** exception while preserving the original stack. Use when translating across a boundary.
- **Never** `throw e` — loses the stack trace.

```dart
// ✅ rethrow — same type, same instance
on TransactionException {
  rethrow;
}

// ✅ throwWithStackTrace — new domain exception, original stack preserved
} catch (_, stack) {
  Error.throwWithStackTrace(const TransactionFetchException(), stack);
}
```

---

## Dependency Injection: Constructor-Based

- Constructor-based DI (no GetIt or service locator)
- `InheritedWidget` at feature scope
- `Scope` pattern: `FeatureScope(create: BlocFactory)` + `AppScope(dependencies)`
- Each feature has its own `di/` directory with Scope and BlocFactory

---

## Feature Organization

Feature = **BLoC + DI + View only** — no domain or data code inside a feature.
Domain and data are shared exclusively via packages.

```
lib/feature/<feature>/
├── <flow>/         # Per-flow sub-folder (list/, setup/, detail/, ...)
│   ├── bloc/       # BLoC + State + Event for this flow
│   ├── di/         # Scope + BlocFactory for this flow
│   └── view/       # Screens and widgets for this flow
└── shared/         # Optional: widgets shared across flows of this feature
```

### Sub-Feature Folders (per flow)

A feature is a Bounded Context UI representation. Each user flow inside it (list, create, detail, settings, ...) gets its own sub-folder with **its own BLoC + Scope + View**. This keeps BLoCs small and prevents god-objects.

### Cross-Feature Communication

Features are independent Bounded Contexts. They **must not** import each other's `bloc/` or `domain/`. Allowed channels:

- **AppEventBus** — typed events (`sealed class AppEvent`) for cross-feature notifications
- **Router** — composition point (`AppRouterDelegate.build()`)
- **AppScope** — shared dependencies (repositories, use cases) wired once at app level
- **Shared UI** — importing another feature's `shared/` widget is acceptable

Direct BLoC-to-BLoC subscription across features is forbidden — it couples Bounded Contexts.

---

## Domain Model Policy

**Never** use API/database types in domain layer:
- Decoupling from API changes
- Type safety with domain enums
- Testability without API dependencies
- Use factory constructors for mapping: `fromApi()`, `fromDb()`, `tryFromApi()`

---

## Testing Discipline

### Test double placement

Test doubles (fakes, mocks, stubs) **never** live inline in a test file or as private `_Class` at the bottom. Each lives in its own file under a role-named subfolder.

```
test/feature/<feature>/
  <test_name>_test.dart
  fakes/
    fake_<name>.dart        ← working in-memory implementation
  mocks/
    mock_<name>.dart        ← mocktail/mockito, verifies interactions
```

**No `helpers/` folder.** Use `fakes/` or `mocks/` only.

### xUnit taxonomy

- `Fake*` — working simplified implementation
- `Mock*` — mocktail/mockito; verifies call expectations
- `Stub*` — minimal concrete; returns fixed values; no expectations
- `Spy*` — records calls for later assertion without blocking

### Test through interfaces, not implementations

Unit-test consumers through interface fakes/mocks. **Never** mock dependencies of an `*Impl` to test the impl itself — that tests implementation details. Impls are tested via integration tests against the real external system.

```dart
// ❌ Tests GatewayImpl by mocking its internal http.Client
final gateway = BlockGenerationGatewayImpl(rpcClient: BitcoinRpcClient(..., client: mockHttp));

// ✅ Test the BLoC through a fake gateway
final bloc = RegtestMiningBloc(blockGenerationGateway: FakeBlockGenerationGateway());
```

### mocktail constraints

- Mock `abstract class` or `abstract interface class` only — **never** `final class`.
- Declaration: `class MockFoo extends Mock implements FooInterface {}`
- Prefer `Fake*` over `Mock*` when you don't need to assert call counts or argument capture.

---

## Generic Design Rules

### Wrapper over parallel maps

When a `Map<String, X>` needs additional metadata per entry (e.g. `isStochastic`), do **not** add a parallel `Map<String, bool>` — it duplicates the same name-as-identity fragility (silent overwrite on duplicate key) and couples two structures by a string.

Introduce a typed wrapper instead:

```dart
final class StrategyResult {
  final String name;
  final bool isStochastic;
  final Result result;
}
```

Use `List<StrategyResult>` (preserves order) or `Map<String, StrategyResult>` (lookup by name).

### In-house over small external deps

For utility-class candidates under ~250 LOC (mixins, wrapper widgets, small helpers), prefer an **in-house implementation in `lib/core/`** over an external dependency, even when the dep is maintained and stable.

Rationale: control over maintenance and naming, fewer transitive dependencies, freedom to improve point-by-point, no opacity for the reader. Workflow:

1. Code-review the reference implementation (from pasted source or `~/.pub-cache/hosted/pub.dev/<pkg>-<ver>/`)
2. List concrete improvements with justification
3. Final version in `lib/core/<topic>/` with naming aligned to project conventions

---

## Code Optimization Rules

- **Function length**: decompose methods over ~80 lines
- **No magic numbers**: all numeric literals (except 0, 1, -1) must be named constants
- **No dead code**: version control preserves history
- **Single responsibility**: if describing a method requires "and", split it
- **Loop complexity**: filter → transform → accumulate as separate pipeline steps

---

## Working Method

### Verify library claims via pub-cache

Before asserting how a third-party library is structured (a class exists, a mixin is exposed, a method signature), **read the source** in `~/.pub-cache/hosted/pub.dev/<package>-<version>/` and cite `file.dart:line`.

```bash
find ~/.pub-cache -path '*<package>-<version>*/lib/src/*.dart'
grep -rn '<ClassName>' <path>
```

Applies to all roles writing implementation or review notes about library internals — `researcher`, `planner`, `implementer`, `reviewer`. The `dart` MCP server's `read_package_uris` and `rip_grep_packages` tools achieve the same with lower token cost; prefer them when available.

Rationale: model guesses about library APIs are wrong often enough that one citation per non-trivial claim saves a round of corrections.

---

## Hard Rules (Never Violate)

```
No `!` null assertion — extract to local variable, null-check
No `dynamic` — use `Object` or `Object?`
No `print` — use `dart:developer` log or project logger
No Cubit — BLoC only
No GetIt or service locator — constructor DI + InheritedWidget
No private `_buildXxx` methods — extract as separate widget classes
No relative imports — always `package:` imports
No `BlocProvider.value` — always `BlocProvider(create: ...)`
No passing BLoC as constructor parameter to a Widget — use `context.read<T>()`
No `BlocProvider(create: (_) => widget.bloc)` — hands lifecycle to provider while BLoC was created externally
No `^` in dependency versions — exact versions only
No repository/service implementations inside a feature directory — use module `data/`
No entities or interfaces inside a feature directory — use module `domain/`
No imports from another feature's `bloc/` or `domain/` — cross-feature only via event bus or router
No imports of module `src/data/*` from features — use public API (barrel) only
No god-object BLoCs handling multiple flows — one BLoC per flow
No `Exception?` field in BLoC state — errors are actions, not state
No `error` value in status enum — same reason
No broad `catch (e, stack)` in use cases without all four criteria (change abstraction / hide secrets / add context / can recover)
No `throw e` — use `rethrow` or `Error.throwWithStackTrace(newException, stack)`
No inline test doubles — `fakes/` or `mocks/` subfolders only, never `helpers/`
No mocktail on `final class` — only `abstract class` or `abstract interface class`
No mocking dependencies of `*Impl` to unit-test the impl — test through interfaces
Never commit with analyzer warnings/infos
```
