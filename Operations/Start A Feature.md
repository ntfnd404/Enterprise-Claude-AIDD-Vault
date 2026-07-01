# Start A Feature

## Шаг 1: Выбрать работу из roadmap

В `docs/project/roadmap.md`:

- выберите planned ticket; или
- назначьте ticket ID элементу `BL-NNN`.

Одна работа не может одновременно находиться в нескольких lifecycle-секциях.

## Шаг 2: Создать ветку

```bash
git checkout -b <TICKET>-<description>
```

## Шаг 3: Создать рабочее пространство

```text
/aidd-new-ticket <TICKET> [BL-NNN]
```

Создаёт:
- перевод roadmap-записи в `In-flight`
- `docs/<TICKET>/.active_ticket`
- `docs/<TICKET>/idea-<TICKET>.md`
- `docs/<TICKET>/tasklist-<TICKET>.md`

## Шаг 4: Заполнить идею

Обязательные поля:
- `Lane` — Professional или Critical
- `Status` — `IDEA_READY` когда заполнение завершено
- `Problem` — в чём проблема
- `Business Goal` — зачем это строить
- `Scope` — что входит в объём
- `Non-goals` — что исключено
- `Dependencies` — что должно существовать заранее
- `Acceptance Criteria` — когда считается готовым

## Шаг 5: Выбрать полосу (Lane)

| Lane | Когда использовать |
|---|---|
| Trivial | Только микро-фиксы (опечатка, переименование) |
| Professional | Почти всегда |
| Critical | Аутентификация, криптография, секреты, хранилище, миграции, API-контракты |

Если не уверены — выбирайте Critical. См. [[../Methodology/Lanes]].

## Шаг 6: Построить каркас фазы

Маршрутизация через подготовительных агентов:

1. **Analyst** — пишет PRD
2. **Researcher** — пишет исследование, обновляет vision
3. **Planner** — пишет план, бриф фазы, таск-лист

Результат: артефакты фазы в состоянии `PLAN_APPROVED` + `TASKLIST_READY`.

## Правило

Не начинайте реализацию, пока не достигнуты `PLAN_APPROVED` и `TASKLIST_READY`.

## Далее

Переходите к [[Prepare A Phase]].
