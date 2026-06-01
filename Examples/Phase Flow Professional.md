# Phase Flow Professional

> **Workflow Minor: 3.3** — пример отражает поток v3.2 (Clarification round, spec-critic gate, Verifiable AC, docs-sync). Для коротких правок без архитектурного влияния см. [[Phase Flow Trivial]] и [[../Methodology/Lanes]].

## Сценарий

Фича: `PROJ-0001` -- добавление экрана настроек приложения.
Полоса: **Professional**.
Фаза: **2** (фаза 1 уже завершена -- создана доменная модель настроек).

## Предусловия

- Идея заполнена и находится в статусе `IDEA_READY`
- Ветка создана: `git checkout -b PROJ-0001-settings-screen`
- Рабочее пространство создано: `/aidd-new-ticket PROJ-0001`

## Полный поток фазы

### Шаг 1: Старт фазы

Пользователь вводит:

```text
/aidd-start-phase 2
```

Скилл запускает маршрутизацию через подготовительных агентов.

### Шаг 1a: Clarification round (analyst)

До формирования PRD агент analyst проводит раунд уточнений — 3-5 нумерованных вопросов к пользователю (формат + правила отказа описаны в [[../Runtime/Agents Reference#Analyst]]). Ответы фиксируются в секции `## Clarification round` PRD как пронумерованные Q/A пары. Минимум 3 пары — обязательное требование валидатора при `Workflow Minor: 3.3`.

### Шаг 2: Analyst создает PRD

Агент analyst читает идею и создает `docs/PROJ-0001/prd/PROJ-0001-phase-2.prd.md`:

- **Deliverables**: экран настроек, переключатели темы и уведомлений, сохранение в локальное хранилище
- **Позитивный сценарий**: пользователь переключает тему -- приложение перезагружается в новой теме
- **Негативный сценарий**: хранилище недоступно -- показывается сообщение об ошибке
- **Метрика успеха**: все настройки сохраняются и восстанавливаются между сессиями
- **Verifiable AC**: каждая ячейка `Success Metrics → Verification` начинается с префикса `test:` / `command:` / `manual:` (правило формата описано в шаблоне `phase_prd.md` и проверяется валидатором).

Статус фазы: `PRD_READY`.

### Шаг 2a: Spec-critic gate

Агент spec-critic читает только PRD (ни discovery, ни кода, ни research) и пишет критику в `docs/PROJ-0001/critique/PROJ-0001-phase-2-critique.md`:

- Минимум 3 наблюдения с числовыми ID `F1`, `F2`, `F3`, …
- Вердикт: `SPEC_CRITIQUED` (можно идти дальше) или `SPEC_BLOCKED` (требуется ревизия PRD).
- При `SPEC_BLOCKED` analyst исправляет Blocking-находки, spec-critic перезапускается; артефакт критики дописывается, не перезаписывается. Бюджет — два цикла ревизии до эскалации.

После чистого прохода статус PRD флипается `PRD_READY` → `SPEC_CRITIQUED`. Только тогда researcher получает право читать кодовую базу.

### Шаг 3: Researcher собирает контекст

Агент researcher анализирует кодовую базу и создает `docs/PROJ-0001/research/PROJ-0001-phase-2.research.md`:

- Текущая модель настроек: `Settings` entity в `packages/domain/`
- Существующий репозиторий: `SettingsRepository` с `getSettings()`, но без `saveSettings()`
- Хранилище: `SharedPreferences` уже подключен как зависимость
- Риск: нет механизма миграции при добавлении новых полей настроек
- Неизвестное: нужно ли поддерживать немедленное применение темы без перезапуска

Также обновляет `docs/PROJ-0001/vision/PROJ-0001.vision.md` архитектурой фичи.

### Шаг 4: Planner создает план и бриф

Агент planner создает `docs/PROJ-0001/plan/PROJ-0001-phase-2.md`:

- Добавить `saveSettings()` в интерфейс `SettingsRepository`
- Реализовать в `SettingsRepositoryImpl` через `SharedPreferences`
- Создать `SettingsBloc` с событиями: `ThemeToggled`, `NotificationsToggled`, `SettingsSaved`
- Создать `SettingsScreen` с переключателями
- Подключить маршрут `/settings`
- Обновить экспорты пакетов

Также создает `docs/PROJ-0001/brief/PROJ-0001-phase-2.brief.md` с разбивкой на батчи и условиями остановки.

Обновляет `docs/PROJ-0001/tasklist/tasklist-PROJ-0001.md`.

Статус фазы: `PLAN_APPROVED` + `TASKLIST_READY`.

### Шаг 5: Implementer работает батчами

#### Батч 1: Domain + Data слой

Implementer предлагает батч:

> **Батч 1**: Добавить `saveSettings()` в интерфейс `SettingsRepository`, реализовать в `SettingsRepositoryImpl`, обновить экспорты пакетов `domain` и `data`.

Пользователь одобряет. Implementer реализует:

1. Добавляет метод в интерфейс
2. Реализует через `SharedPreferences`
3. Обновляет barrel-файлы экспортов

Запуск проверок:

```text
/aidd-run-checks
```

Проверки:
- `dart format` -- форматирование OK
- `dart analyze` -- анализ OK (zero warnings)
- `flutter test` -- тесты проходят

Implementer обновляет `phase-2.md` и `tasklist-PROJ-0001.md`, показывает diff, останавливается на границе.

#### Батч 2: BLoC + UI + маршрут

Implementer предлагает батч:

> **Батч 2**: Создать `SettingsBloc` с событиями и состояниями, создать `SettingsScreen` с формой, подключить маршрут `/settings`.

Пользователь одобряет. Implementer реализует:

1. Создает `SettingsBloc`, `SettingsEvent`, `SettingsState`
2. Создает `SettingsScreen` с виджетами переключателей
3. Добавляет маршрут в роутер
4. Обновляет экспорты

Запуск проверок:

```text
/aidd-run-checks
```

Все проверки проходят. Implementer обновляет артефакты, показывает diff.

### Шаг 6: Reviewer проверяет

Агент reviewer анализирует все изменения:

- Изменения соответствуют плану
- Конвенции соблюдены (см. [[../Methodology/Artifact Contracts]])
- Нет регрессий в существующем коде
- Вердикт: `REVIEW_OK`

Результат записывается в `docs/PROJ-0001/summary/PROJ-0001-phase-2.summary.md`.

### Шаг 7: QA проверяет сценарии

Агент qa запускает верификацию по PRD:

- **PS-1**: Переключить тему -- приложение применяет новую тему -- PASS
- **PS-2**: Выключить уведомления -- настройка сохранена -- PASS
- **NE-1**: Хранилище недоступно -- ошибка отображается корректно -- PASS
- **IV-1**: Статический анализ чист -- PASS
- **IV-2**: Все unit-тесты проходят -- PASS
- Вердикт: `QA_PASS`

Результат записывается в `docs/PROJ-0001/qa/PROJ-0001-phase-2.qa.md`.

### Шаг 8: Завершение фазы

Перед запуском `/aidd-complete-phase` проходит чек-лист закрытия (см. [[../Checklists/Complete Phase Professional]]), в том числе пункт **Docs sync**: «Изменилось ли поведение, описанное в `docs/project/`? Если да — обновлено ли `docs/project/` в этом же PR?». Вердикт `yes` / `no` / `N-A` фиксируется в phase summary.

Пользователь вводит:

```text
/aidd-complete-phase 2
```

Скилл проверяет, что все гейты пройдены: `REVIEW_OK` + `QA_PASS`. Фаза закрывается.

## Автоматические ограждения во время потока

| Хук | Что делает |
|---|---|
| **PreToolUse** | Блокирует редактирование, если нет `.active_ticket` |
| **PostToolUse** | Автоформатирование каждого исходного файла после редактирования |
| **PostCompact** | Восстанавливает тикет, фазу, полосу и цель при сжатии контекста |

## Условия остановки

Implementer останавливается, если:

- Батч завершен -- ждет одобрения следующего
- Обнаружен блокер
- Отклонение от архитектуры (план и код расходятся)
- Обнаружен риск, не описанный в research
- Достигнута граница гейта

## Полная цепочка гейтов

```
IDEA_READY → PRD_READY → SPEC_CRITIQUED → RESEARCH_DONE → VISION_SET →
PLAN_APPROVED → TASKLIST_READY → IMPLEMENT_STEP_OK →
REVIEW_OK → QA_PASS → PHASE_DONE
```

Гейт `SPEC_CRITIQUED` обязателен для всех фаз при `Workflow Minor: 3.3` (исключение — bootstrap-карвоут, описанный в `Methodology/Overview.md`).

## Ссылки

- [[../Operations/Run A Professional Phase]] -- операционная инструкция
- [[../Methodology/Lanes]] -- определение полос
- [[../Methodology/Artifact Contracts]] -- контракты артефактов
