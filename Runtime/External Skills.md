# Внешние Agent Skills

Слой переиспользуемых skill-паков от вендоров (Flutter team, Dart team и будущих). Каталог карточек — в отдельном vault [Skills](obsidian://open?vault=Skills&file=Home).

## Доктрина

> **MCP даёт инструменты. Skill учит, как использовать инструменты для задачи. AIDD оркестрирует, какой skill срабатывает на каком гейте.**

Три слоя, не конфликтующие между собой:

| Слой | Источник | Что даёт | Как обновляется |
|---|---|---|---|
| MCP | `.mcp.json` / settings | низкоуровневые тулзы (analyze, lsp, hot_reload) | вместе с серверами MCP |
| Внешние skills | `flutter/skills`, `dart-lang/skills` | рецепты «как сделать задачу» | `npx skills update` или git pull |
| AIDD skills | `.claude/skills/aidd-*` | workflow-команды (`/aidd-*`) | вручную, версия воркфлоу |

## Установка

В каждом проекте, использующем стек Flutter/Dart:

```bash
# Через CLI (требует node/npx)
npx skills add flutter/skills    --skill '*' --agent universal
npx skills add dart-lang/skills  --skill '*' --agent universal

# Без node — прямой git clone (см. Update Process в Skills vault)
```

Skills попадают в `.claude/skills/` рядом с локальными `aidd-*`. Конфликтов имён нет — внешние skills имеют префиксы `flutter-*` / `dart-*`.

## Конвенция совместного существования

| Аспект | Внешние skills | AIDD skills |
|---|---|---|
| Префикс | `flutter-`, `dart-` | `aidd-` |
| Активация | по описанию (Claude решает) | только `/aidd-*` (manual) |
| `disable-model-invocation` | `false` (или отсутствует) | `true` |
| Владелец | вендор (Google) | этот воркфлоу |
| Версионирование | upstream | `Workflow Version` |

**Правило конфликта:** если внешний skill противоречит `docs/project/conventions.md` или ADR — приоритет у проекта. См. оверлеи в [[../Tech Adaptors/Flutter-Dart/external-skills-overlay]].

## Маппинг на гейты

Полная матрица: [[../Tech Adaptors/Flutter-Dart/gate-skill-matrix]].

Краткая идея:

```
PLAN_APPROVED        → dart-resolve-package-conflicts, flutter-setup-*
TASKLIST_READY       → flutter-add-integration-test (preparation)
IMPLEMENT_STEP_OK    → flutter-add-widget-test, dart-add-unit-test,
                        flutter-build-responsive-layout, dart-use-pattern-matching,
                        dart-fix-runtime-errors, flutter-fix-layout-issues
                        + dart-run-static-analysis (через /aidd-run-checks)
REVIEW_OK            → dart-run-static-analysis (повторная проверка диффа)
QA_PASS              → flutter-add-integration-test, dart-collect-coverage (Critical)
```

## Ограничения

- Внешние skills auto-invokable — Claude может вызвать skill самостоятельно, если описание совпадает с задачей. Это нормальное поведение, но в Critical lane любой такой авто-вызов должен попадать в phase summary.
- Внешние skills не заменяют security-reviewer и QA-гейты — они помогают внутри них, но не закрывают.

## Каталог карточек

[Skills vault → Home](obsidian://open?vault=Skills&file=Home)

- 10 Flutter skills под `Catalog/Flutter/`
- 9 Dart skills под `Catalog/Dart/`
- Мета: шаблон карточки, MCP-зависимости, процесс обновления
