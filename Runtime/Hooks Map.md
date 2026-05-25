# Карта хуков

## Таблица хуков

| Событие | Назначение | Скрипт | Режим |
|---|---|---|---|
| `InstructionsLoaded` | Напоминание об активном рабочем процессе и дисциплине полосы | `instructions-loaded.sh` | async |
| `SessionStart` (compact) | Восстановление контекста тикета/фазы после компактификации | `session-compact.sh` | sync |
| `PreToolUse` (Write/Edit) | Блокировка записи в защищённые файлы, проверка наличия активного тикета | `pre-edit-guard.sh` | sync + statusMessage |
| `PostToolUse` (Write/Edit) | Автоформатирование исходных файлов после каждого редактирования | `post-edit-format.sh` | sync + statusMessage |
| `PostCompact` | Восстановление тикета/фазы/полосы/цели после компактификации контекста | `post-compact-reinject.sh` | sync |
| `FileChanged` | Ревалидация процессного слоя при изменении файлов рабочего процесса | `file-changed-guard.sh` | sync + statusMessage |
| `ConfigChange` | Валидация изменений настроек и скиллов | `config-change-guard.sh` | sync + statusMessage |
| `SubagentStart` | Уведомление о правилах делегирования | `subagent-lifecycle.sh start` | async |
| `SubagentStop` | Уведомление о порядке гейтов | `subagent-lifecycle.sh stop` | async |
| `TaskCreated` | Оркестрация командного режима | `team-task-lifecycle.sh created` | async |
| `TaskCompleted` | Оркестрация командного режима | `team-task-lifecycle.sh completed` | async |
| `TeammateIdle` | Сигнал ребалансировки в командном режиме | `team-task-lifecycle.sh idle` | async |

Все скрипты находятся в `.claude/hooks/`.

### Опциональный локальный git-хук

| Скрипт | Назначение | Установка |
|---|---|---|
| `git-pre-commit.sh` | Запускает `aidd_validate.sh` перед каждым коммитом — ловит process drift до пуша | `cp .claude/hooks/git-pre-commit.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit` |

Это **НЕ** часть Claude Code hooks (не объявляется в `settings.json`), а опциональное локальное усиление. Не включается автоматически — каждый разработчик решает сам.

## Детали по каждому событию

### InstructionsLoaded

Срабатывает при загрузке инструкций проекта в начале сессии. Хук работает в режиме async -- не блокирует выполнение и не инъектирует данные в контекст Claude. Служит исключительно как advisory-уведомление.

### SessionStart

Срабатывает при возобновлении сессии после компактификации (matcher: `compact`). Работает синхронно, инъектирует в контекст Claude информацию об активном тикете. Выводит сообщение вида:

```
Session resumed after compaction. Active ticket: <TICKET>. Re-read phase brief and plan.
```

### PreToolUse

Срабатывает перед каждым вызовом инструмента Write, Edit или MultiEdit (matcher: `Write|Edit|MultiEdit`). Три уровня проверки:

1. **Защищённые файлы** -- `.git/`, `.env`, `secrets/`, `.claude/settings.local.json` -- всегда блокируется (exit 2)
2. **Гейт активного тикета** -- исходные директории (настраиваются через `$AIDD_SOURCE_DIRS`) без `.active_ticket` -- блокируется
3. **Файлы рабочего процесса** -- `CLAUDE.md`, `AGENTS.md`, templates, `.claude/*` -- разрешается с advisory-предупреждением

Использует `statusMessage` для отображения спиннера в UI без расхода токенов контекста.

### PostToolUse

Предоставляется Tech Adaptor. Автоформатирует исходные файлы после каждого Write/Edit/MultiEdit. Форматирует только файлы, соответствующие паттерну языка адаптора (например, `.dart` для Flutter, `.ts` для TypeScript). Это отдельный механизм от `/aidd-run-checks` -- код остаётся отформатированным в процессе работы, а не только при проверке.

### PostCompact

Самый ценный хук. При компактификации контекста Claude теряет всю рабочую память. PostCompact инъектирует одну строку:

```
Context restored. Ticket: <TICKET> | Phase: N | Lane: <lane> | Goal: <goal>.
Re-read phase brief and plan before continuing.
```

Требует наличия заголовков `Lane:` и `Goal:` в phase brief.

### FileChanged

Срабатывает при изменении файлов рабочего процесса (matcher: `CLAUDE\.md|AGENTS\.md|docs/project/.*|\.claude/.*`). Запускает быструю валидацию через `aidd_validate.sh --quick`. Использует `statusMessage` для UI-уведомления.

### ConfigChange

Срабатывает при изменении настроек проекта или скиллов (matcher: `project_settings|skills`). Запускает быструю валидацию аналогично FileChanged. Использует `statusMessage`.

### SubagentStart / SubagentStop

Срабатывают при запуске и завершении субагентов. Оба работают в режиме async -- advisory-уведомления без инъекции в контекст. Не блокируют выполнение.

### TaskCreated / TaskCompleted / TeammateIdle

Хуки командного режима. Срабатывают только при `AIDD_TEAM_MODE=1`. Все три работают в режиме async. При выключенном командном режиме (`AIDD_TEAM_MODE=0`) события подавляются -- скрипт завершается сразу.

## Оптимизация токенов

### async vs sync

| Режим | Когда использовать | Влияние на токены |
|---|---|---|
| `async: true` | Уведомительные хуки (advisory-уведомления жизненного цикла) | Не блокирует, 0 токенов рассуждения |
| sync (по умолчанию) | Проверки гейтов, инъекция контекста, форматирование | Блокирует до завершения, может инъектировать токены |

6 из 12 событий хуков выполняются async. Только проверки гейтов и инъекция контекста требуют sync.

### statusMessage vs systemMessage

| Режим | Когда использовать | Влияние на токены |
|---|---|---|
| `statusMessage` | Хук информирует только пользователя (спиннер, статус валидации) | Показывает спиннер в UI, 0 токенов в контексте |
| stdout (systemMessage) | Claude нужна информация (восстановление контекста PostCompact) | Инъектируется в контекст, стоит токенов |

Правило: если хук информирует только пользователя -- используйте `statusMessage`. Если Claude нужна информация -- пишите в stdout.

Подробнее об экономии токенов см. [[../Methodology/Token Optimization]].

## Структура в settings.json

Хуки настраиваются в `.claude/settings.json` в секции `hooks`:

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<regex-паттерн>",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/<script>.sh\"",
            "timeout": 10,
            "async": true,
            "statusMessage": "Описание для UI..."
          }
        ]
      }
    ]
  }
}
```

Ключевые поля:

| Поле | Описание |
|---|---|
| `matcher` | Regex-паттерн для фильтрации (например, `Write\|Edit\|MultiEdit` или `.*`) |
| `type` | Всегда `command` в закоммиченном конфиге |
| `command` | Bash-команда для выполнения, используйте `$CLAUDE_PROJECT_DIR` для безопасных путей |
| `timeout` | Тайм-аут в секундах (обычно 10-20) |
| `async` | `true` для advisory-хуков, отсутствует или `false` для sync |
| `statusMessage` | Текст спиннера в UI (0 токенов контекста) |

## Правила проектирования хуков

- Хуки прозрачны (всегда понятно, что они делают)
- Хуки не мутируют молча отслеживаемые файлы
- Хуки используют только тип `command` в закоммиченном конфиге
- Все пути используют `$CLAUDE_PROJECT_DIR` для безопасности
- Git hooks -- это НЕ часть основного рабочего процесса, только опциональное локальное усиление

## Доступность по уровням

| Хук | Lite | Standard | Enterprise |
|---|---|---|---|
| InstructionsLoaded | Да | Да | Да |
| PreToolUse | Да | Да | Да |
| PostToolUse | Да (если есть адаптор) | Да | Да |
| PostCompact | Да | Да | Да |
| FileChanged | Да | Да | Да |
| ConfigChange | Да | Да | Да |
| SessionStart | Нет | Да | Да |
| SubagentStart/Stop | Нет | Да | Да |
| TaskCreated/Completed/Idle | Нет | Нет | Да |

См. [[../Methodology/Tier System]] для полного сравнения уровней.
