# BLoC Communication

Workflow Version: 3

Rules for coordinating independent BLoCs without making them know about each
other.

---

## Principle

Do not frame cross-feature coordination as "Bloc A talks to Bloc B". With proper
decoupling, both BLoCs depend on a shared third thing:

- a source of truth for state, or
- a typed event channel for facts.

BLoCs must not import another feature's `bloc/`, read another BLoC through
`context.read<OtherBloc>()`, subscribe to another BLoC's stream, or use
`BlocListener<OtherBloc, ...>` for cross-feature coordination.

`BlocListener` is for UI side effects in the same presentation subtree
(navigation, SnackBar, dialog), not BLoC-to-BLoC wiring.

---

## Decision Matrix

Ask these questions in order.

### 1. Is it state or a fact?

| Need | Meaning | Use |
|---|---|---|
| State | There is a current value and consumers care about "how is it now?" | State stream from a source of truth |
| Fact | Something happened at a moment in time; there is no current value | `AppEventBus` typed event |

Examples of state: current user, selected account, session lock, theme,
connectivity, current WebRTC role.

Examples of facts: stream started, stream stopped, payment completed,
session logged out, peer connected.

### 2. If it is state, where does the state live?

| State kind | Abstraction | Layer / owner | Examples |
|---|---|---|---|
| Persisted, remote, OS-backed, or database-backed | Reactive repository or gateway with `current` + `Stream` / watch API | Owning package `domain` contract + `data` implementation | auth status from storage, settings from storage, Drift watch query |
| Ephemeral app runtime state with no external source | Application service / store with current value + `Stream` | Owning package `application`, or `lib/core` only when app-wide shell state | session lock, selected in-memory room, cross-screen draft |
| One-time fact | `AppEventBus` typed event | `lib/core/event_bus` event contract | broadcast completed, peer connected, wallet funded |

The stream is not the architecture. The source of truth is. A repository is
correct only when it wraps a real data source. An in-memory mailbox used only to
coordinate two BLoCs is a service/store, not a repository.

---

## Allowed Patterns

### Shared State

Use this when consumers need the current value and future changes.

```text
Source of truth (repository/gateway/service/store)
  ▲ mutates / reads                 ▲ watches
Bloc A                              Bloc B
```

Rules:

- The source exposes a current value and a stream of changes.
- A BLoC subscribes in its constructor, maps changes to an internal event, and
  cancels in `close()`.
- Both BLoCs know only the shared abstraction, not each other.
- If only one consumer should mutate the state, expose a read-only interface for
  other consumers.

### Event Bus

Use this when consumers need to react to a fact and no current value exists.

```text
AppEventBus
  ▲ emit                            ▲ subscribe/filter
Bloc A                              Bloc B
```

Rules:

- Emit typed `sealed class AppEvent` events.
- Subscribers filter by event type.
- Subscribers translate bus events into internal BLoC events.
- Cancel subscriptions in `close()`.
- Do not reconstruct current state from event history.

### Composition-Time Parameters

If two BLoCs only need the same initial parameter, compute it once from the same
source of truth and pass it to both factories.

```dart
final initialRole = intent.initialWebRtcRole;
final homeBloc = HomeScope.createBloc(context, intent: intent);
final callBloc = CallScope.createBloc(context, role: initialRole);
```

Do not create one BLoC and read its state to create another BLoC when the value
already comes from a shared input such as route intent.

### Coordination

If the requirement is "when A and B are both ready, do C", do not spread that
logic across A and B. Create an explicit coordinator:

- a use case / application service when it belongs to business or application
  workflow, or
- a dedicated BLoC when it is a presentation workflow.

The coordinator depends on sources. The coordinated BLoCs stay independent.

---

## Anti-Patterns

- Passing a BLoC into another BLoC.
- Importing another feature's `bloc/`.
- `context.read<OtherBloc>()` for cross-feature coordination.
- One BLoC subscribing to another BLoC's `stream`.
- `BlocListener<OtherFeatureBloc, ...>` to drive another feature.
- Event bus for state.
- Repository with no real data source.
- Global god-bus carrying unrelated state and commands.
- Empty one-method use cases that only delegate to a repository/service with no
  added rule, translation, or orchestration.

---

## Layer Notes

Use cases are application-layer business rules: they orchestrate a user or system
operation. Domain-layer business rules are invariants of the business concepts
themselves.

Do not put use cases in `domain/`. Put them in an owning package's
`application/` layer when they add real value. If the operation is pure
delegation, call the repository/gateway/service directly.

For app-only presentation flows, `lib/feature/*` remains `bloc/di/view` only.
If shared state or coordination becomes reusable business/application logic,
promote it into the owning package instead of adding `application/` inside the
feature.
