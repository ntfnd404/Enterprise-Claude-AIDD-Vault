# Справочник агентов

## Обзор

AIDD использует 7 специализированных агентов. Каждый имеет определённые входные данные, выходные артефакты и ответственность за гейт.

## Таблица агентов

| Агент | Читает | Пишет | Гейт |
|---|---|---|---|
| **analyst** | idea | PRD | `IDEA_READY` -> `PRD_READY` |
| **researcher** | idea, PRD, кодовую базу | research, vision | `PRD_READY` -> `RESEARCH_DONE` |
| **planner** | vision, PRD, research | plan, brief, tasklist | `RESEARCH_DONE` -> `PLAN_APPROVED` |
| **implementer** | brief, plan, PRD, conventions | исходный код, phase, tasklist | `TASKLIST_READY` -> `IMPLEMENT_STEP_OK` |
| **reviewer** | diff, plan, PRD, conventions | phase summary | `IMPLEMENT_STEP_OK` -> `REVIEW_OK` |
| **security-reviewer** | diff, plan, PRD, review | security review | `REVIEW_OK` -> `SECURITY_REVIEW_OK` |
| **qa** | PRD, phase, plan, review/security | QA report | `REVIEW_OK` -> `QA_PASS` |

## Детали по каждому агенту

### analyst

**Роль:** Собирает требования и создаёт PRD фазы. Не проектирует реализацию.

**Входные данные:**

| Файл | Назначение |
|---|---|
| `docs/<TICKET>/idea-<TICKET>.md` | Скоуп и намерение фичи |
| `docs/project/conventions.md` | Архитектурные правила |

**Выходные артефакты:**

| Артефакт | Путь |
|---|---|
| Phase PRD | `docs/<TICKET>/prd/<TICKET>-phase-N.prd.md` |

**Правила:**
- Описывает deliverables, сценарии и метрики успеха
- Не предлагает файловых решений
- Не пишет код
- Помечает блокирующие вопросы как `Open Questions`

**Гейт:** `IDEA_READY` -> `PRD_READY`

### researcher

**Роль:** Исследует кодовую базу и окружение. Производит факты, не проектные решения.

**Входные данные:**

| Файл | Назначение |
|---|---|
| `docs/<TICKET>/idea-<TICKET>.md` | Скоуп фичи |
| `docs/<TICKET>/prd/<TICKET>-phase-N.prd.md` | Требования фазы |
| Кодовая база | Текущее состояние реализации |

**Выходные артефакты:**

| Артефакт | Путь |
|---|---|
| Research | `docs/<TICKET>/research/<TICKET>-phase-N.md` |
| Vision (если новый/обновлённый) | `docs/<TICKET>/vision-<TICKET>.md` |

**Правила:**
- Сообщает только факты из кода или окружения
- Не предлагает шагов реализации
- Помечает риски с оценкой влияния и рекомендацией
- Ссылается на конкретные пути файлов и номера строк

**Гейт:** `PRD_READY` -> `RESEARCH_DONE` / `VISION_APPROVED`

### planner

**Роль:** Проектирует точную форму реализации. План должен быть decision-complete, чтобы implementer не принимал новых архитектурных решений.

**Входные данные:**

| Файл | Назначение |
|---|---|
| `docs/<TICKET>/vision-<TICKET>.md` | Архитектура фичи |
| `docs/<TICKET>/prd/<TICKET>-phase-N.prd.md` | Требования фазы |
| `docs/<TICKET>/research/<TICKET>-phase-N.md` | Факты кодовой базы и риски |
| `docs/project/conventions.md` | Архитектурные правила |

**Выходные артефакты:**

| Артефакт | Путь |
|---|---|
| Plan | `docs/<TICKET>/plan/<TICKET>-phase-N.md` |
| Phase brief | `docs/<TICKET>/phase/<TICKET>/phase-N.md` |
| Обновление tasklist | `docs/<TICKET>/tasklist-<TICKET>.md` |

**Правила:**
- Указывает точные файлы, контракты и последовательность
- Включает обработку ошибок и крайние случаи
- Включает необходимые проверки
- Не пишет исходный код
- Brief должен содержать заголовки `Lane:` и `Goal:` (требуется для восстановления PostCompact)

**Гейт:** `RESEARCH_DONE` -> `PLAN_APPROVED` -> `TASKLIST_READY`

### implementer

**Роль:** Пишет код для текущей фазы, не пересматривая архитектурных решений. Работает связными пакетами и останавливается на значимых границах.

**Входные данные:**

| Файл | Назначение |
|---|---|
| `docs/<TICKET>/.active_ticket` | Идентификатор текущего тикета |
| `docs/<TICKET>/phase/<TICKET>/phase-N.md` | Пакет выполнения |
| `docs/<TICKET>/plan/<TICKET>-phase-N.md` | Дизайн реализации |
| `docs/<TICKET>/prd/<TICKET>-phase-N.prd.md` | Критерии приёмки |
| `docs/project/conventions.md` | Архитектурные правила |
| `docs/project/code-style-guide.md` | Правила стиля |

**Выходные артефакты:**

| Артефакт | Обновление |
|---|---|
| Исходные файлы | Модификация согласно плану |
| `docs/<TICKET>/tasklist-<TICKET>.md` | Отметка выполненных элементов |
| `docs/<TICKET>/phase/<TICKET>/phase-N.md` | Отметка выполненных элементов |

**Цикл выполнения:**
1. Прочитать текущие phase, plan и PRD
2. Определить следующий связный пакет
3. Предложить пакет и ожидать явного одобрения
4. Реализовать только этот пакет
5. Запустить необходимые проверки
6. Обновить phase и tasklist
7. Показать diff и объяснить, что изменилось
8. Остановиться на значимой границе

**Правила пакетов:**
- Professional: 2-5 связанных задач, если они образуют одну логическую единицу
- Critical: меньшие пакеты с более узким скоупом
- Немедленная остановка при: отклонении от архитектуры, блокере, обнаружении риска

**Гейт:** `TASKLIST_READY` -> `IMPLEMENT_STEP_OK`

### reviewer

**Роль:** Ревьюит завершённую реализацию на корректность, соответствие плану, регрессии и соблюдение конвенций.

**Входные данные:**

| Файл | Назначение |
|---|---|
| Code diff | Что изменилось |
| `docs/<TICKET>/plan/<TICKET>-phase-N.md` | Ожидаемая реализация |
| `docs/<TICKET>/prd/<TICKET>-phase-N.prd.md` | Критерии приёмки |
| `docs/project/conventions.md` | Архитектурные правила |

**Выходные артефакты:**

| Артефакт | Путь |
|---|---|
| Review summary | `docs/<TICKET>/<TICKET>-phase-N-summary.md` |

**Правила:**
- Сначала пишет находки: блокирующие, важные, отклонения
- Проверяет регрессии
- Проверяет соблюдение конвенций
- Не переписывает код -- сообщает о находках
- Вердикт: `REVIEW_OK` или `BLOCKING`

**Гейт:** `IMPLEMENT_STEP_OK` -> `REVIEW_OK`

### security-reviewer

**Роль:** Выполняет security-ревью фаз полосы Critical. Проверяет утечки чувствительных данных, нарушения границ доверия и небезопасные фоллбэки.

**Только полоса Critical.** Не участвует в полосе Professional.

**Входные данные:**

| Файл | Назначение |
|---|---|
| Code diff | Что изменилось |
| `docs/<TICKET>/plan/<TICKET>-phase-N.md` | Ожидаемое поведение |
| `docs/<TICKET>/prd/<TICKET>-phase-N.prd.md` | Требования |
| `docs/<TICKET>/<TICKET>-phase-N-summary.md` | Находки ревью |

**Выходные артефакты:**

| Артефакт | Путь |
|---|---|
| Security review | `docs/<TICKET>/security/<TICKET>-phase-N.md` |

**Проверки:**
- Секреты и чувствительные данные никогда не логируются
- Приватный материал остаётся в правильном слое
- Обработка ошибок не раскрывает состояние безопасности
- Изменения storage/network/auth соответствуют плану
- Не введён небезопасный фоллбэк или путь понижения

**Правила:**
- Ревьюит только аспекты, связанные с безопасностью
- Не переписывает код
- Вердикт: `SECURITY_REVIEW_OK` или `SECURITY_REVIEW_BLOCKED`

**Гейт:** `REVIEW_OK` -> `SECURITY_REVIEW_OK`

### qa

**Роль:** Верифицирует реализацию фазы по сценариям PRD и создаёт QA-отчёт на основе доказательств.

**Входные данные:**

| Файл | Назначение |
|---|---|
| `docs/<TICKET>/prd/<TICKET>-phase-N.prd.md` | Сценарии и критерии |
| `docs/<TICKET>/phase/<TICKET>/phase-N.md` | Phase brief |
| `docs/<TICKET>/plan/<TICKET>-phase-N.md` | Дизайн реализации |
| `docs/<TICKET>/<TICKET>-phase-N-summary.md` | Находки ревью |
| `docs/<TICKET>/security/<TICKET>-phase-N.md` | Находки безопасности (Critical) |

**Выходные артефакты:**

| Артефакт | Путь |
|---|---|
| QA report | `docs/<TICKET>/qa/<TICKET>-phase-N.md` |

**Категории сценариев:**
- **PS** -- Positive Scenarios (happy path)
- **NE** -- Negative / Edge Scenarios
- **MC** -- Manual Checks (UI, устройство, runtime)
- **IV** -- Implementation Verification (анализ, конвенции)

**Правила:**
- Сначала пишет доказательства
- Ссылается на конкретные файлы и поведение
- Не перепроектирует архитектуру
- Вердикт: `QA_PASS` или `QA_FAIL`

**Гейт:** `REVIEW_OK` / `SECURITY_REVIEW_OK` -> `QA_PASS`

## Поток артефактов

```
idea
  |
  v
[analyst] --> PRD
  |
  v
[researcher] --> research, vision
  |
  v
[planner] --> plan, brief, tasklist
  |
  v
[implementer] --> source code, phase/tasklist updates
  |
  v
[reviewer] --> phase summary
  |
  v (только Critical)
[security-reviewer] --> security review
  |
  v
[qa] --> QA report
```

## Поля frontmatter агентов

Каждый агент определяется в `.claude/agents/<name>.md`:

```yaml
---
name: <role>
description: Когда использовать этого агента
model: inherit
tools: Read, Write, Edit, Glob, Grep, Bash
---
```

| Поле | Описание |
|---|---|
| `name` | Имя роли (например, `implementer`) |
| `description` | Claude использует для определения, когда делегировать этому агенту |
| `model` | Модель для использования (`inherit` = та же, что у вызывающего) |
| `tools` | Список разрешённых инструментов |

## Ограничения инструментов по агентам

| Агент | Инструменты | Обоснование |
|---|---|---|
| analyst | Read, Glob, Grep, Write | Без Bash, без Edit -- только чтение и создание артефактов |
| researcher | Read, Glob, Grep, Bash, Write | Bash нужен для исследования кодовой базы |
| planner | Read, Glob, Grep, Write | Без Bash, без Edit -- проектирование, не реализация |
| implementer | Read, Write, Edit, Glob, Grep, Bash | Полный набор инструментов -- единственная роль с правом записи кода |
| reviewer | Read, Glob, Grep, Write | Пишет только review summary |
| security-reviewer | Read, Glob, Grep, Write | Пишет только security review |
| qa | Read, Glob, Grep, Write | Пишет только QA report |

## Ключевые правила проектирования

### Разделение ролей

**Implementer -- единственная роль с правом записи кода.** Все остальные роли создают артефакты (PRD, research, plan, review, QA), но не изменяют исходный код.

Каждый агент читает только необходимые ему артефакты -- без избыточной загрузки.

### Конвенции -- это runtime, не уровень агента

Проектно-специфичные правила живут в `docs/project/conventions.md`, который агенты читают в runtime. Определения агентов универсальны и не зависят от проекта.

## Пользовательские агенты

Для доменных рабочих процессов создавайте дополнительных агентов в `.claude/agents/`. Примеры:
- `devops.md` -- деплоймент инфраструктуры
- `data-engineer.md` -- скрипты миграции
- `api-designer.md` -- ревью API-контрактов

## Доступность по уровням

| Агент | Lite | Standard | Enterprise |
|---|---|---|---|
| analyst | Да | Да | Да |
| researcher | Нет (включён в planner) | Да | Да |
| planner | Да | Да | Да |
| implementer | Да | Да | Да |
| reviewer | Да | Да | Да |
| security-reviewer | Нет | Да | Да |
| qa | Да | Да | Да |

См. [[../Methodology/Tier System]] для полного сравнения уровней.
См. [[../Methodology/Roles And Gates]] для детального описания гейтов.
