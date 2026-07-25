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


## Adversarial Spec Review

Перед переходом к реализации выполните критический проход по PRD/plan:

- Professional lane: рекомендуется.
- Critical lane: обязательно перед `PLAN_APPROVED`.

Цель: найти противоречия, implicit assumptions, overscope, questionable tech choices и acceptance criteria, которые нельзя проверить. Это мягкое правило: новый gate status не добавляется. Результат должен быть отражен в PRD/plan/brief, если найденные проблемы меняют scope или реализацию.

## Ожидаемые артефакты

| Файл | Автор |
|---|---|
| `prd/<TICKET>-phase-N.prd.md` | Analyst |
| `research/<TICKET>-phase-N.md` | Researcher |
| `vision-<TICKET>.md` | Researcher |
| `plan/<TICKET>-phase-N.md` | Planner |
| `phase/<TICKET>/phase-N.md` | Planner |

## Git checkpoint спецификации

После `PLAN_APPROVED` и `TASKLIST_READY`, но до первого изменения исходного
кода:

1. Покажите полный diff только спецификации: idea, PRD, critique, research,
   vision, plan, phase brief и tasklist. Показывайте совокупный diff от точки
   ответвления feature branch, а не только текущие незакоммиченные изменения.
2. Получите явное принятие спецификации владельцем.
3. Отдельно запросите разрешение на commit.
4. Создайте commit:
   `aidd(<TICKET>): approve phase <N> specification baseline`. Он содержит только файлы
   спецификации либо может быть пустым, если принятые артефакты уже находятся в
   отдельных preparation commits.
5. Убедитесь, что immutable-артефакты спецификации (`idea`, `prd`, `critique`,
   `research`, `vision`, `plan`) чисты.

Если разрешение на commit не получено, реализация приостанавливается. Если
позже меняются принятые требования, архитектура, scope или design реализации,
сначала покажите specification-only diff и создайте отдельно одобренный commit
`aidd(<TICKET>): amend phase <N> specification baseline`. Обновления состояния выполнения
в brief/tasklist могут входить в implementation commits.

Это обязательная Git-граница, а не новый gate status. Первоначальную
спецификацию и первые изменения кода нельзя объединять в один commit. Разрешение
на push всегда запрашивается отдельно.

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
- Не создан и не проверен Git checkpoint спецификации

## Далее

- Профессиональная фаза: [[Run A Professional Phase]]
- Критическая фаза: [[Run A Critical Phase]]
