# Справочник скиллов

## Скиллы рабочего процесса

Все скиллы рабочего процесса используют `disable-model-invocation: true` -- они вызываются только вручную через `/command`.

| Скилл | Назначение | Уровень | Оптимизация |
|---|---|---|---|
| `/aidd-init` | Инициализация AIDD в новом или существующем проекте | Все | -- |
| `/aidd-new-ticket <TICKET>` | Создание рабочего пространства фичи с заглушками idea + tasklist | Все | -- |
| `/aidd-new-phase N` | Подготовка артефактов фазы (PRD, research, plan, brief) | Standard+ | -- |
| `/aidd-start-phase N` | Загрузка контекста фазы, предложение первого пакета | Все | `effort: medium` |
| `/aidd-run-checks` | Конвейер format + analyze + lint + test | Все | `context: fork`, `effort: low` |
| `/aidd-complete-phase N` | Закрытие фазы, маршрутизация в review/qa | Standard+ | `effort: high` |
| `/aidd-validate` | Проверка целостности процессного слоя | Standard+ | `context: fork`, `effort: low` |
| `/aidd-ship-feature` | Проверка готовности к релизу и синхронизация документации | Все | -- |

## Детали по каждому скиллу

### /aidd-init

Инициализирует рабочий процесс AIDD v3 в проекте.

**Синтаксис:**
```
/aidd-init --tier <lite|standard|enterprise> --adaptor <flutter-dart|node-typescript|go|custom> --prefix <PREFIX>
/aidd-init --adopt --tier standard
```

**Аргументы:**
- `--tier` -- уровень методологии (по умолчанию: standard)
- `--adaptor` -- технический стек (по умолчанию: none)
- `--prefix` -- префикс тикетов (по умолчанию: PROJ)
- `--adopt` -- режим адаптации для существующих проектов

**Что делает:**
1. Создаёт `.claude/` с settings.json, agents, skills, hooks
2. Создаёт `docs/project/` с workflow.md, conventions, style guide, templates
3. Генерирует CLAUDE.md и AGENTS.md
4. Применяет Tech Adaptor (если указан): хук PostToolUse, overlay конвенций, конвейер проверок
5. Применяет настройки уровня (количество агентов/скиллов/хуков)
6. Запускает валидацию
7. Отчитывается о созданных файлах и следующих шагах

**Режим адаптации** (`--adopt`): сканирует существующую структуру `.claude/` и `docs/`, добавляет недостающие компоненты без перезаписи существующих.

**Порождаемые агенты:** нет
**Создаваемые артефакты:** `.claude/*`, `docs/project/*`, `CLAUDE.md`, `AGENTS.md`

### /aidd-new-ticket

Создаёт рабочее пространство для нового тикета.

**Синтаксис:**
```
/aidd-new-ticket <TICKET>
```

**Что делает:**
1. Создаёт `docs/<TICKET>/.active_ticket` с идентификатором тикета
2. Создаёт `docs/<TICKET>/idea-<TICKET>.md` из шаблона idea
3. Создаёт `docs/<TICKET>/tasklist-<TICKET>.md` из шаблона tasklist
4. Отчитывается о созданных файлах

**После создания:** заполнить idea-документ разделами Problem, Business Goal, Scope, Non-goals, Dependencies, Acceptance Criteria, Lane.

**Порождаемые агенты:** нет
**Создаваемые артефакты:** `.active_ticket`, `idea-<TICKET>.md`, `tasklist-<TICKET>.md`

### /aidd-new-phase

Подготавливает артефакты для новой фазы.

**Синтаксис:**
```
/aidd-new-phase N
```

**Что делает:**
1. Читает `.active_ticket` для получения текущего тикета
2. Создаёт `docs/<TICKET>/prd/<TICKET>-phase-N.prd.md` из шаблона PRD
3. Создаёт `docs/<TICKET>/research/<TICKET>-phase-N.md` из шаблона research
4. Создаёт `docs/<TICKET>/plan/<TICKET>-phase-N.md` из шаблона plan
5. Создаёт `docs/<TICKET>/phase/<TICKET>/phase-N.md` из шаблона brief
6. Отчитывается о созданных файлах и маршрутизации: analyst -> researcher -> planner

**Порождаемые агенты:** analyst, researcher, planner (последовательно)
**Создаваемые артефакты:** PRD, research, plan, phase brief
**Читаемые артефакты:** `.active_ticket`

### /aidd-start-phase

Загружает контекст фазы и предлагает первый пакет реализации.

**Синтаксис:**
```
/aidd-start-phase N
```

**Что делает:**
1. Читает `.active_ticket`
2. Читает phase brief: `docs/<TICKET>/phase/<TICKET>/phase-N.md`
3. Читает plan: `docs/<TICKET>/plan/<TICKET>-phase-N.md`
4. Читает PRD: `docs/<TICKET>/prd/<TICKET>-phase-N.prd.md`
5. Читает `docs/project/conventions.md`
6. Определяет следующий связный пакет из чеклиста выполнения
7. Предлагает пакет и ожидает одобрения

**Важно:** НЕ начинает реализацию. Только предлагает пакет.

**Порождаемые агенты:** implementer (после одобрения пакета)
**Читаемые артефакты:** `.active_ticket`, phase brief, plan, PRD, conventions

### /aidd-run-checks

Запускает конвейер проверок качества проекта.

**Синтаксис:**
```
/aidd-run-checks
```

**Что делает:**
1. Читает `.claude/aidd-checks.sh`
2. Если файл существует -- выполняет его
3. Если файл не существует -- сообщает об отсутствии конфигурации и предлагает запустить настройку Tech Adaptor

**Ожидаемый конвейер** (последовательно, останавливается на первом сбое):
1. Format -- только изменённые исходные файлы
2. Analyze -- статический анализ с нулевой толерантностью
3. Lint -- дополнительные правила (зависят от стека)
4. Test -- полный набор тестов

**Формат отчёта:** каждая проверка как PASS или FAIL с деталями по сбоям.

**Порождаемые агенты:** нет
**Читаемые артефакты:** `.claude/aidd-checks.sh`

### /aidd-complete-phase

Завершает фазу и маршрутизирует в конвейер ревью и QA.

**Синтаксис:**
```
/aidd-complete-phase N
```

**Что делает:**
1. Читает `.active_ticket`
2. Читает phase brief и проверяет, что все элементы выполнения отмечены
3. Обновляет статус фазы на `IMPLEMENT_STEP_OK`
4. Определяет полосу из phase brief
5. Маршрутизирует:
   - Professional: reviewer -> qa
   - Critical: reviewer -> security-reviewer -> qa
6. Отчитывается о завершении и следующих шагах

**Порождаемые агенты:** reviewer, security-reviewer (только Critical), qa
**Читаемые артефакты:** `.active_ticket`, phase brief

### /aidd-validate

Проверяет целостность процессного слоя AIDD.

**Синтаксис:**
```
/aidd-validate
```

**Что делает:**
1. Выполняет `.claude/bin/aidd_validate.sh`
2. Отчитывается о результатах

**Что проверяет валидатор:**
- Существование обязательных файлов рабочего процесса (CLAUDE.md, AGENTS.md, `docs/project/*`)
- Контракт метаданных шаблонов (Status, Ticket, Phase, Lane, Workflow Version: 3, Owner)
- Покрытие событий хуков в settings.json
- Целостность скиллов
- Обнаружение устаревших ссылок
- Валидация документации активных фич
- Предупреждения о прогрессии гейтов (idea без Status, `TASKLIST_READY` с 0 задач)

**Порождаемые агенты:** нет
**Читаемые артефакты:** все файлы рабочего процесса

### /aidd-ship-feature

Проверка готовности к мержу и синхронизация документации.

**Синтаксис:**
```
/aidd-ship-feature
```

**Что делает:**
1. Читает `.active_ticket`
2. Проверяет, что все фазы прошли (review + QA, security для Critical)
3. Запускает `/aidd-validate`
4. Проверяет, что tasklist полностью зелёный
5. Определяет долгосрочные знания для продвижения в `docs/project/`
6. Проверяет, что `docs/<TICKET>/` исключена из мержа
7. Отчитывается о готовности к релизу

**Чеклист продвижения:**
- Новые постоянные правила -> `docs/project/conventions.md`
- Архитектурные решения -> `docs/project/adr/`
- Улучшения процесса -> `docs/project/workflow.md` или шаблоны
- Улучшения валидатора -> `.claude/bin/aidd_validate.sh`

**Порождаемые агенты:** нет
**Читаемые артефакты:** `.active_ticket`, все phase/qa/review артефакты, tasklist

## Поля frontmatter скиллов

| Поле | Назначение | Допустимые значения |
|---|---|---|
| `name` | Имя slash-команды | `aidd-run-checks` и т.д. |
| `description` | Когда использовать | Claude использует это для решения об автовызове |
| `disable-model-invocation` | Только ручной вызов | `true` для всех скиллов рабочего процесса |
| `context` | Контекст выполнения | `fork` для validate/checks (изолированный контекст) |
| `effort` | Глубина рассуждения | `low` (механические), `medium` (загрузка контекста), `high` (сложная маршрутизация) |
| `paths` | Паттерны активации по файлам | Для доменных скиллов (`docker/**`, `migrations/**`) |
| `allowed-tools` | Ограничение инструментов | `Bash Read`, `Read Write Bash Glob` и т.д. |

Подробнее о влиянии frontmatter на токены см. [[../Methodology/Token Optimization]].

## Внешние Agent Skills

Помимо `/aidd-*` рабочего процесса, проект может использовать внешние skill-паки от вендоров (Flutter team, Dart team). Они **auto-invokable** (без `disable-model-invocation`) и срабатывают по описанию задачи.

- Доктрина и установка: [[External Skills]]
- Каталог карточек: [Skills vault → Home](obsidian://open?vault=Skills&file=Home)
- Маппинг на гейты Flutter/Dart: [[../Tech Adaptors/Flutter-Dart/gate-skill-matrix]]

| Слой | Префикс | Auto-invoke | Владелец |
|---|---|---|---|
| AIDD workflow | `aidd-*` | нет (manual) | этот воркфлоу |
| Внешние | `flutter-*`, `dart-*` | да | вендор |
| Доменные | произвольный | по `paths:` | проект |

## Типы skills и plugins

| Тип | Префикс / пример | Может закрывать AIDD gate | Владелец |
|---|---|---|---|
| Workflow skills | `/aidd-*` | Да, только по контракту конкретного `/aidd-*` | AIDD vault |
| Stack execution skills | `dart-*`, `flutter-*` | Нет | Вендор / Tech Adaptor |
| Superpowers execution methodology | `/brainstorming`, `/execute-plan`, TDD, debugging, code-reviewer | Нет | Superpowers plugin |
| Domain/project-specific skills | project-specific names | Нет, если явно не оформлены как AIDD workflow skills | Проект |

`/aidd-*` остаются единственными workflow-командами. Остальные skills/plugins помогают внутри роли и gate.

## Доменные скиллы

Доменные скиллы -- проектно-специфичные. Примеры:

- Bitcoin RPC операции (paths: `docker/**`, `Makefile`)
- AWS деплоймент (paths: `infra/**`, `terraform/**`)
- Миграции баз данных (paths: `migrations/**`)

Доменные скиллы обычно используют:
- `paths` для загрузки только при активных релевантных файлах
- `context: fork` для изоляции вывода от основного контекста
- `effort: low` для механических операций

## Создание пользовательских скиллов

Создайте файл `.claude/skills/<skill-name>/SKILL.md`:

```yaml
---
name: my-skill
description: Что делает этот скилл и когда его использовать
disable-model-invocation: true
allowed-tools: Bash Read
context: fork
effort: low
---

Инструкции для Claude при вызове этого скилла.
Используйте $ARGUMENTS для аргументов пользователя.
```

Вспомогательные файлы размещаются в той же директории:
```
.claude/skills/my-skill/
  SKILL.md          # Основные инструкции
  template.md       # Шаблон вывода
  scripts/
    helper.sh       # Скрипты, которые Claude может запускать
```

## Доступность по уровням

| Скилл | Lite | Standard | Enterprise |
|---|---|---|---|
| `/aidd-init` | Да | Да | Да |
| `/aidd-new-ticket` | Да | Да | Да |
| `/aidd-new-phase` | Нет | Да | Да |
| `/aidd-start-phase` | Да | Да | Да |
| `/aidd-run-checks` | Да | Да | Да |
| `/aidd-complete-phase` | Нет | Да | Да |
| `/aidd-validate` | Нет | Да | Да |
| `/aidd-ship-feature` | Да | Да | Да |

См. [[../Methodology/Tier System]] для полного сравнения уровней.
