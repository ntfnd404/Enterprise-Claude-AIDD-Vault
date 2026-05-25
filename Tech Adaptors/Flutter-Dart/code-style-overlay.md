# Flutter-Dart Code Style Overlay

These rules are appended to `docs/project/code-style-guide.md` when the Flutter-Dart adaptor is applied.

---

## Formatting

- Page width: **120 characters**
- **Always** use trailing commas in multi-line constructs
- **Always** use curly braces in `if`/`for`/`while` — never omit
- **Always** use single quotes for strings
- **Always** add blank line before `return` when preceding code exists (except arrow functions)

## Naming

| Construct | Convention | Example |
|-----------|-----------|---------|
| Classes / Interfaces | `UpperCamelCase` | `WalletRepository` |
| Implementations | `UpperCamelCase` + `Impl` | `WalletRepositoryImpl` |
| Enums | `UpperCamelCase` | `WalletStatus` |
| Enum values | `lowerCamelCase` | `WalletStatus.loading` |
| Methods / fields | `lowerCamelCase` | `generateAddress` |
| Private members | `_lowerCamelCase` | `_walletRepository` |
| Files | `snake_case.dart` | `wallet_repository.dart` |
| Constants | `lowerCamelCase` | `defaultTimeout` |

## Class Member Ordering

Flutter framework convention (verified in `EdgeInsets`, `Container`, `TextButton` source):

1. Constructors (production first, then named, factory, then `@visibleForTesting`)
2. Static const / static final fields
3. Instance fields — final, then late, then nullable (public before private within each)
4. Getters / computed properties
5. Public methods
6. Dispose / close
7. Private methods

Constructors first, static fields second, instance fields last. This matches DCM `member-ordering`.

```dart
// ❌
class Foo {
  static const _timeout = 30; // static before constructor — wrong
  const Foo();
  final String _id;
}

// ✅
class Foo {
  const Foo();
  static const _timeout = 30; // static after constructor
  final String _id;            // instance fields last
}
```

### Widget Member Ordering

1. `const` / `final` fields
2. Constructors
3. `var` / mutable fields
4. `initState`
5. `didChangeDependencies`
6. `didUpdateWidget`
7. `build`
8. `dispose`
9. Public methods
10. Private methods

### BLoC Member Ordering

1. Final repository/service fields
2. Constructor with `super.initialState` + `on<>` registrations
3. Private fields (subscriptions)
4. Event handlers (private, `_onEventName`)
5. `close` override

## Type Safety

- **Always** declare return types — never omit
- **Always** use `final` for non-reassigned locals
- **Always** use `const` for compile-time constants
- **Never** use `var` when type is not obvious from the right side
- **Never** use `dynamic` — use `Object` or `Object?`

## Async Patterns

- **Always** check `isClosed` before `emit()` after async gaps in BLoC
- **Never** ignore Futures — use `unawaited()` if fire-and-forget
- **Always** cancel subscriptions in `dispose` / `close`

## Widget Lifecycle

`StatefulWidget` lifecycle order in source:

1. `initState`
2. `didChangeDependencies` / `didUpdateWidget`
3. `build`
4. `dispose`

- **Always** use `const` constructors where possible
- Arrow functions only for single-expression bodies — multi-line bodies use `{ ... return; }`
- **Never** create private `_buildXxx` methods — extract as separate widget classes

## InheritedWidget Access in State

**Never** call `context.read<T>()`, `context.watch<T>()`, or any `InheritedWidget`-based lookup inside `initState` — the widget is not yet in the tree and the lookup will throw.

**Always** use `didChangeDependencies` with an `_initialized` guard for `late final` fields that depend on `InheritedWidget`:

```dart
class _MyState extends State<MyWidget> {
  late final MyDependency _dep;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    _dep = context.read<MyDependency>();
  }
}
```

The guard is mandatory when the field is `late final` — assigning it twice throws `LateInitializationError`. `didChangeDependencies` can be called multiple times (e.g., when an ancestor `InheritedWidget` updates).

## BLoC Lifecycle

- **Scope** = high in tree, exposes a **factory** for creating BLoC instances via static method + `InheritedWidget`. Scope does **not** hold or own BLoC instances.
- **`BlocProvider(create: ...)`** = low in tree, near the screen / `BlocBuilder`. Auto-disposes the BLoC when removed.
- **One BLoC per flow** — no god-object BLoCs handling multiple flows.

```dart
// Scope: high in tree, exposes factory
class WalletListScope extends StatefulWidget {
  const WalletListScope({required this.child});
  final Widget child;

  static WalletListBloc newBloc(BuildContext context) {
    final scope = context
        .getInheritedWidgetOfExactType<_InheritedWalletListScope>();
    if (scope == null) {
      throw StateError('WalletListScope not found in widget tree');
    }

    return scope.newBloc();
  }
  // ...
}

// Screen: BlocProvider(create:) low in tree
class WalletListScreen extends StatelessWidget {
  const WalletListScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<WalletListBloc>(
    create: (_) => WalletListScope.newBloc(context),
    child: const _WalletListView(),
  );
}
```

## Use Cases

For use cases with a **single method**, name it `call` instead of `execute`. This allows invoking the use case instance as a function.

```dart
// ❌ Legacy
class GetWalletsUseCase {
  Future<List<Wallet>> execute() => _repository.getWallets();
}
// await useCase.execute()

// ✅ Modern
class GetWalletsUseCase {
  Future<List<Wallet>> call() => _repository.getWallets();
}
// await useCase()
```

Multi-method services keep explicit method names — `call` is reserved for single-purpose use cases.

## Import Organization

1. `dart:` imports
2. `package:flutter/` imports
3. `package:` third-party imports
4. `package:` project imports (alphabetical)

**Always** use `package:` imports, never relative imports.

```dart
// ❌
import '../local/wallet_local_store.dart';

// ✅
import 'package:data/src/local/wallet_local_store.dart';
```

## Examples

### Correct

```dart
// Good: null-safe, typed, formatted
final String? name = user.name;
if (name != null) {
  final greeting = 'Hello, $name';

  return greeting;
}
```

### Incorrect

```dart
// Bad: null assertion, missing type, no braces
final greeting = 'Hello, ${user.name!}';
if (condition) return greeting; // no braces, no blank line
```
