# Flutter-Dart: Gate ↔ Skill Matrix

Сопоставление гейтов AIDD v3.1 и внешних skills для Flutter/Dart стека.

См. также: [[../../Methodology/Roles And Gates]], [[external-skills-overlay]].

## Матрица

| Гейт | Роль | AIDD skill | Внешние skills (опциональны) | Триггер |
|---|---|---|---|---|
| `IDEA_READY → PRD_READY` | analyst | `/aidd-new-ticket` (idea), затем `/aidd-new-phase` (PRD) | — | анализ требований не требует код-skills |
| `PRD_READY → RESEARCH_DONE` | researcher | — | `flutter-apply-architecture-best-practices` | при сомнении в архитектурной шкале |
| `RESEARCH_DONE → VISION_APPROVED` | researcher | — | `flutter-apply-architecture-best-practices` | то же |
| `VISION_APPROVED → PLAN_APPROVED` | planner | — | `flutter-setup-declarative-routing`, `flutter-setup-localization`, `dart-resolve-package-conflicts` | one-shot setup-задачи в плане |
| `PLAN_APPROVED → TASKLIST_READY` | planner | `/aidd-new-phase` | — | tasklist собирается из плана |
| `TASKLIST_READY → IMPLEMENT_STEP_OK` | implementer | `/aidd-start-phase`, `/aidd-run-checks` | `flutter-add-widget-test`, `flutter-add-widget-preview`, `flutter-build-responsive-layout`, `flutter-fix-layout-issues`, `flutter-implement-json-serialization`, `dart-add-unit-test`, `dart-generate-test-mocks`, `dart-use-pattern-matching`, `dart-fix-runtime-errors`, `dart-run-static-analysis` | по типу батча |
| `IMPLEMENT_STEP_OK → REVIEW_OK` | reviewer | — | `dart-run-static-analysis` | повторная верификация диффа |
| `REVIEW_OK → SECURITY_REVIEW_OK` (Critical) | security-reviewer | — | — | security review — ручной gate, skills не помогают |
| `SECURITY_REVIEW_OK / REVIEW_OK → QA_PASS` | qa | `/aidd-complete-phase` | `flutter-add-integration-test`, `flutter-add-widget-test`, `dart-add-unit-test`, `dart-collect-coverage` | по типу purposes из PRD |
| `QA_PASS → RELEASE_READY → DOCS_UPDATED` | (orchestrator) | `/aidd-ship-feature`, `/aidd-validate` | — | финал — без code-skills |

## Привязка по типу батча

Когда планер собирает batch, он выбирает skills по сигнатуре работы:

| Тип батча | Рекомендованные skills |
|---|---|
| Новая UI-фича | `flutter-add-widget-preview` → `flutter-build-responsive-layout` → `flutter-add-widget-test` |
| Новый use case / domain | `dart-use-pattern-matching` (для sealed) + `dart-add-unit-test` + `dart-generate-test-mocks` |
| Bug fix (runtime) | `dart-fix-runtime-errors` (или `flutter-fix-layout-issues` для UI) |
| Refactor | `dart-use-pattern-matching` + повторный `dart-run-static-analysis` |
| Setup-фаза | `dart-resolve-package-conflicts`, при необходимости `flutter-setup-*` |
| Critical QA | `flutter-add-integration-test` + `dart-collect-coverage` обязательны |

## Lane-минимумы

| Lane | Минимальный набор внешних skills для прохождения гейтов |
|---|---|
| Trivial | `dart-run-static-analysis`, по ситуации `dart-fix-runtime-errors` / `flutter-fix-layout-issues` |
| Professional | + `dart-add-unit-test` или `flutter-add-widget-test` (если изменение поведенческое) |
| Critical | + `dart-collect-coverage` (QA evidence), + `flutter-add-integration-test` (UI Critical) |

## Conventions override

Все skills исполняются в контексте `docs/project/conventions.md`. Конфликт разрешается в пользу проекта — это закреплено в [[external-skills-overlay#Приоритеты при конфликте]].

## Superpowers overlay

| Ситуация | Superpowers aid | Ограничение |
|---|---|---|
| Нечеткий scope или PRD | `/brainstorming` | Результат переносится в AIDD artifacts |
| PRD/plan может быть противоречивым | Adversarial spec review | Professional: рекомендуется; Critical: обязательно |
| Реализация поведения | TDD | Внутри approved batch |
| Runtime bug / QA_FAIL / flaky test | Systematic debugging | Сначала root cause |
| Batch готов к реализации | `/execute-plan` | Только после `TASKLIST_READY` и approval |
| Перед официальным ревью | code-reviewer | Pre-review, не `REVIEW_OK` |

Superpowers не является gate closer. AIDD roles and artifacts remain authoritative.

## DDD / Security Batch Triggers

- DDD/package-boundary changes: use architecture review aids plus static analysis; Critical when trust boundaries move.
- Secrets/redaction/storage/crypto changes: Critical lane; security-reviewer remains mandatory.
