# Инициализация нового проекта

## Цель

Полная настройка рантайма AIDD v3.2 в новом проекте с нуля.

## v3.2: что обязательно учесть при бутстрапе

1. В шапке проектного `CLAUDE.md` укажите `Workflow Minor: 3.2` (поле `Workflow Version` остаётся `3`).
2. Скопируйте scaffold-документы из vault в корень нового проекта:
   - `Templates/Project Docs/CLAUDE.md` → `<project_root>/CLAUDE.md`
   - `Templates/Project Docs/vision.md` → `docs/project/vision.md`
   - `Templates/Project Docs/roadmap.md` → `docs/project/roadmap.md`
3. В разделе lanes проектного `CLAUDE.md` перечислите все три полосы: `Trivial / Professional / Critical`. Trivial — короткий путь `edit → review` для опечаток, переименований и точечных конфигов; коммит обязан нести префикс `trivial:` либо ссылку на issue.
4. Discovery-шаблон опционален: копируйте `Templates/Artifacts/discovery.md` в проект только если фича стартует с фазы Discovery.

## Предварительные требования

- Установлен Claude Code
- Инициализирован Git-репозиторий
- Известен технический стек (Flutter/Dart, Node/TypeScript, Go и т.д.)

## Шаг 0: Установка seed-скилла

`/aidd-init` — это скилл Claude Code. Он должен физически существовать в `.claude/skills/` проекта, прежде чем его можно вызвать. В новом проекте его ещё нет — поэтому сначала скопируйте его вручную из vault.

```bash
mkdir -p .claude/skills/aidd-init

cp "<PATH_TO_VAULT>/Templates/Runtime/skills/aidd-init--SKILL.md" \
   .claude/skills/aidd-init/SKILL.md
```

Замените `<PATH_TO_VAULT>` на путь к этому Obsidian vault. После копирования скилл появится в Claude Code и можно вызывать `/aidd-init`.

## Шаг 1: Запуск инициализации

```text
/aidd-init --tier standard --adaptor flutter-dart --prefix BW
```

### Параметры

| Параметр | Значения | По умолчанию | Назначение |
|---|---|---|---|
| `--tier` | `lite`, `standard`, `enterprise` | `standard` | Определяет количество агентов/навыков/хуков |
| `--adaptor` | `flutter-dart`, `node-typescript`, `go`, `custom` | нет | Наложения, специфичные для стека |
| `--prefix` | любые заглавные буквы | `PROJ` | Префикс тикетов (например BW, AG) |

### Что создаётся

```
.claude/
├── settings.json           # Конфигурация хуков (универсальная + адаптер)
├── agents/                 # 5-7 определений агентов (зависит от тира)
│   ├── analyst.md
│   ├── researcher.md       # Только Standard+
│   ├── planner.md
│   ├── implementer.md
│   ├── reviewer.md
│   ├── security-reviewer.md # Только Standard+
│   └── qa.md
├── skills/                 # 5-8 навыков воркфлоу (зависит от тира)
│   ├── aidd-init/
│   ├── aidd-new-ticket/
│   ├── aidd-new-phase/     # Только Standard+
│   ├── aidd-start-phase/
│   ├── aidd-run-checks/
│   ├── aidd-complete-phase/ # Только Standard+
│   ├── aidd-validate/      # Только Standard+
│   └── aidd-ship-feature/
├── hooks/                  # 6-12 скриптов хуков (зависит от тира)
│   ├── instructions-loaded.sh
│   ├── session-compact.sh
│   ├── pre-edit-guard.sh
│   ├── post-compact-reinject.sh
│   ├── post-edit-format.sh  # Из технического адаптера
│   ├── file-changed-guard.sh
│   ├── config-change-guard.sh
│   ├── subagent-lifecycle.sh
│   └── team-task-lifecycle.sh # Только Enterprise
└── bin/
    └── aidd_validate.sh

docs/
└── project/
    ├── workflow.md           # Универсальный (одинаковый для всех проектов)
    ├── conventions.md        # Заготовка + наложение адаптера
    ├── code-style-guide.md   # Заготовка + наложение адаптера
    ├── guidelines.md         # Заготовка
    └── templates/            # Все шаблоны артефактов
        ├── idea.md
        ├── vision.md
        ├── tasklist.md
        ├── phase_prd.md
        ├── phase_plan.md
        ├── phase_brief.md
        ├── phase_research.md
        ├── phase_summary.md
        ├── phase_qa.md
        ├── phase_security_review.md
        └── adr.md

CLAUDE.md                    # Инструкции проекта для Claude
AGENTS.md                    # Полный справочник агентов
```

Если указан адаптер, дополнительно:
- Добавляется хук `PostToolUse` для автоформатирования
- Заполняется `conventions.md` правилами, специфичными для стека
- Заполняется `code-style-guide.md` стилем, специфичным для стека
- Создаётся `.claude/aidd-checks.sh` с конвейером format/analyze/test
- Создаётся `.mcp.json`, если адаптер предоставляет MCP-конфигурацию

## Шаг 2: Настройка правил проекта

Заполните сгенерированные заготовки:

1. **`docs/project/conventions.md`** — добавьте правила архитектуры, структуру пакетов, жёсткие запреты
2. **`docs/project/code-style-guide.md`** — добавьте правила стиля проекта сверх дефолтов адаптера
3. **`docs/project/guidelines.md`** — добавьте руководство по фреймворку
4. **Добавьте доменные навыки** в `.claude/skills/`, если в проекте есть специфичные для домена процессы (например Bitcoin RPC, деплой в AWS)

## Шаг 3: Проверка

```text
/aidd-validate
```

Должно показать, что всё в порядке. Если нет — исправьте обнаруженные пробелы.

## Шаг 4: Запуск первой фичи

```text
/aidd-new-ticket <PREFIX>-0001
```

Смотрите [[../Operations/Start A Feature]].

## Переменные окружения

| Переменная | Назначение | По умолчанию |
|---|---|---|
| `AIDD_TIER` | Активный тир | `standard` |
| `AIDD_SOURCE_DIRS` | Директории для проверки гейтов (разделитель — pipe) | `lib/*\|src/*\|packages/*` |
| `AIDD_TEAM_MODE` | Включение хуков командного режима | `0` |
| `AIDD_PROJECT_PREFIX` | Префикс тикетов | из `--prefix` |

Хранятся в `.claude/settings.local.json` (в gitignore) или как переменные окружения.

## Справка по тирам

Смотрите [[../Methodology/Tier System]] для полного сравнения.
