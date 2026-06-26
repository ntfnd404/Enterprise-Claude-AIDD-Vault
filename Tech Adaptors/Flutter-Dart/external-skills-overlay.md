# Flutter-Dart: External Skills Overlay

Какие внешние skills применимы в этом адаптере и где они конфликтуют с проектными конвенциями.

См. также: [[../../Runtime/External Skills]] и [[gate-skill-matrix]].


## Слои исполнения

| Слой | Префикс / команда | Роль |
|---|---|---|
| AIDD workflow skills | `/aidd-*` | Управляют lifecycle и gate progression |
| Flutter/Dart stack skills | `dart-*`, `flutter-*` | 16 unique installed skills для работы внутри AIDD gates |
| Superpowers plugin | `/brainstorming`, `/execute-plan`, TDD, debugging, code-reviewer | Общая методика исполнения; не является gate command |

Flutter/Dart skills выбираются по типу батча. Superpowers может помогать с процессом исполнения, но не заменяет Flutter/Dart conventions и AIDD gates.

## Активный набор

19 catalog rows, разбиты на три категории по применимости. Adaptor устанавливает 16 unique skills из первых двух категорий:

### Полностью применимы (core set)

| Skill | Назначение в адаптере |
|---|---|
| `dart-run-static-analysis` | дополняет `dcm_analyze` в `/aidd-run-checks` |
| `dart-add-unit-test` | основной test-authoring рецепт |
| `dart-generate-test-mocks` | для тестов с RPC / storage зависимостями |
| `dart-collect-coverage` | обязателен в Critical lane |
| `dart-fix-runtime-errors` | recovery после QA_FAIL |
| `dart-use-pattern-matching` | для sealed-типов проекта |
| `dart-resolve-package-conflicts` | на любом гейте до IMPLEMENT |
| `flutter-add-widget-test` | парный к BLoC-виджетам |
| `flutter-add-widget-preview` | для `ui_kit` пакета |
| `flutter-add-integration-test` | QA-уровень для Critical phase |
| `flutter-build-responsive-layout` | UI работа |
| `flutter-fix-layout-issues` | recovery при layout exceptions |
| `flutter-apply-architecture-best-practices` | вторичный — основной источник `conventions.md` |

### Применимы с оговорками (project-specific overrides)

| Skill | Override |
|---|---|
| `flutter-implement-json-serialization` | OK для несекретных DTO; **запрещено** для подписей, ключей, signed-tx — там кастомные коды путей |
| `flutter-setup-declarative-routing` | one-shot — после initial setup не нужен |
| `flutter-setup-localization` | one-shot — после initial setup не нужен |
| `dart-generate-test-mocks` | feedback memory: helpers/fakes выносим в `test/helpers/` отдельным файлом, не inline |

### Неприменимы в текущем проекте

| Skill | Причина |
|---|---|
| `flutter-use-http-package` | сетевые вызовы идут через `rpc_client` workspace package |
| `dart-build-cli-app` | основной артефакт — Flutter app |
| `dart-migrate-to-checks-package` | используется `package:test` + `flutter_test`, миграция не планируется |

Эти карточки остаются в [Skills vault](obsidian://open?vault=Skills&file=Home) для портативности воркфлоу.

## Приоритеты при конфликте

1. `docs/project/conventions.md`
2. `docs/project/adr/*`
3. `docs/project/code-style-guide.md`
4. **Skill**
5. Дефолты Flutter/Dart

Пример: skill `flutter-apply-architecture-best-practices` рекомендует слой Logic с провайдерами/сервисами. В этом проекте: BLoC + sub-feature folders + DI через scope. Конвенции выигрывают.

## Memory-привязки

См. memory-карточки, которые модифицируют поведение skills:
- "BLoC-only + sub-feature folders" → переопределяет state-management части любого Flutter skill
- "Test helpers in separate file" → переопределяет `dart-generate-test-mocks`
- "No relative imports" → постобработка после любого skill, генерирующего код
- "Empty line before return" → постобработка после любого skill, генерирующего код
- "Selective catches in use cases" → переопределяет error-handling части skills
