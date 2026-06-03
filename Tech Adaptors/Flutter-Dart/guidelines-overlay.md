# Flutter-Dart Guidelines Overlay

These rules are appended to `docs/project/guidelines.md` when the Flutter-Dart adaptor is applied.

---

## Framework Patterns

Prefer `StatelessWidget` over `StatefulWidget` wherever possible.
Move state to a BLoC or a `StatefulWidget` ancestor; keep leaf widgets stateless and `const`.

`AppScope` must sit **above** `App` in the widget tree so all features can access dependencies.
Feature scopes live inside `AppRouterDelegate.build()` — above `Navigator`, below `MaterialApp`.

Never read `InheritedWidget` inside `initState`. Use `didChangeDependencies` with `_initialized` guard.

---

## Testing Strategy

Unit-test: domain logic, BLoC event handlers, data mappers, crypto utilities.
Integration-test: full feature flows against real external systems (never mock them).
Never mock internals of `*Impl` — test consumers through interface fakes.

Test doubles location:
```
test/feature/<feature>/
  fakes/   ← working in-memory implementations
  mocks/   ← mocktail/mockito
```

---

## Error Handling

Transient errors → one-shot `Action` → `SnackBar`. Never put them in `State`.
Persistent errors → typed nullable field in `State` only when UI must stay error-visible.
Never use bare `catch (_) {}` — always log, rethrow, or emit an action.

---

## Logging

Use `dart:developer` `log()`. Never `print()`.
Never log: private keys, mnemonics, seeds, raw SDP, connection secrets, wallet addresses.

---

## Performance

Use `const` constructors. Prefer `ListView.builder` for long lists.
Never run expensive work in `build()`. Profile before optimising.

---

## Accessibility

All interactive elements need a semantic label. Minimum tap target: 48×48 dp.
Provide text alternatives for QR codes. Respect system font scaling.

---

## Platform Notes

Always declare required entitlements explicitly on macOS/iOS.
HLS is supported on Android, iOS, macOS, Web only — guard with platform check.
flutter_secure_storage requires `keychain-access-groups` entitlement on macOS.
