# Prepare A Phase

## Цель

Довести фазу до состояния `PLAN_APPROVED` и `TASKLIST_READY`.

## Предусловия

- Рабочее пространство фичи создано через `/aidd-new-ticket`
- Идея заполнена со всеми обязательными полями

## Команды

```text
/aidd-new-phase N
```

Затем маршрутизация:

1. **Analyst** — пишет `prd/<TICKET>-phase-N.prd.md`
2. **Researcher** — пишет `research/<TICKET>-phase-N.md`, обновляет `vision-<TICKET>.md` при необходимости
3. **Planner** — пишет `plan/<TICKET>-phase-N.md` и `phase/<TICKET>/phase-N.md`

Когда все артефакты готовы:

```text
/aidd-start-phase N
```

## Ожидаемые артефакты

| Файл | Автор |
|---|---|
| `prd/<TICKET>-phase-N.prd.md` | Analyst |
| `research/<TICKET>-phase-N.md` | Researcher |
| `vision-<TICKET>.md` | Researcher |
| `plan/<TICKET>-phase-N.md` | Planner |
| `phase/<TICKET>/phase-N.md` | Planner |

## Оптимизация токенов

- `/aidd-start-phase` использует `effort: medium` — сбалансированный режим для чтения контекста фазы
- `/aidd-validate` использует `context: fork` — изолирует вывод валидации от основного контекста

## Предупреждения о прогрессии гейтов

Валидатор предупреждает о:
- Файле идеи без заголовка `Status:`
- `TASKLIST_READY` с 0 отмеченных задач
- Брифе фазы без заголовков `Lane:` или `Goal:`

## Условие остановки

Не переходите к реализации, пока:
- Не установлен `PLAN_APPROVED`
- Не установлен `TASKLIST_READY`

## Далее

- Профессиональная фаза: [[Run A Professional Phase]]
- Критическая фаза: [[Run A Critical Phase]]
