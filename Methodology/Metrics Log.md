---
type: methodology
---

# Лог метрик (`metrics.log`)

`metrics.log` — это append-only журнал прохождения гейтов для одной фичи. Он живёт в рабочем пространстве тикета и используется ретроспективой `aidd-ship-feature` и аудитом.

## Где живёт

`docs/<TICKET>/metrics.log`

Файл создаётся `aidd-complete-phase` при первом проходе фазы. До этого его не существует.

## Формат строки

```
YYYY-MM-DD | phase-N | <GATE> | lane=<Lane> [| <key>=<value>] ...
```

Поля:

| Поле | Источник | Пример |
|---|---|---|
| `YYYY-MM-DD` | дата записи | `2026-04-24` |
| `phase-N` | номер фазы | `phase-3` |
| `<GATE>` | имя гейта, к которому продвинулась фаза | `IMPLEMENT_STEP_OK`, `REVIEW_OK`, `SECURITY_REVIEW_OK`, `QA_PASS` |
| `lane=<Lane>` | полоса фазы | `lane=Critical` |
| `<key>=<value>` (опц.) | дополнительные метрики | `rework=2`, `duration_h=4` |

## Минимальный пример

```
2026-04-22 | phase-1 | IMPLEMENT_STEP_OK | lane=Professional
2026-04-22 | phase-1 | REVIEW_OK | lane=Professional
2026-04-22 | phase-1 | QA_PASS | lane=Professional
2026-04-23 | phase-2 | IMPLEMENT_STEP_OK | lane=Critical
2026-04-23 | phase-2 | REVIEW_OK | lane=Critical
2026-04-23 | phase-2 | SECURITY_REVIEW_OK | lane=Critical
2026-04-24 | phase-2 | QA_PASS | lane=Critical
```

## Кто пишет

| Скилл / агент | Что пишет |
|---|---|
| `aidd-complete-phase` | `IMPLEMENT_STEP_OK` |
| `reviewer` (опц.) | `REVIEW_OK` или `BLOCKING` |
| `security-reviewer` (опц.) | `SECURITY_REVIEW_OK` или `SECURITY_REVIEW_BLOCKED` |
| `qa` (опц.) | `QA_PASS` или `QA_FAIL` |

В минимальной реализации пишет только `aidd-complete-phase`. Полный аудит-режим — все четыре пишут свои гейты.

## Кто читает

- `aidd-ship-feature` — генерирует ретроспективу (количество фаз, lanes, rework count).
- Внешние аудит/отчётные процессы.

## Правила

- **Append-only.** Никогда не редактируйте старые строки.
- **Никаких секретов.** Только имена гейтов и метаданные процесса.
- **Не мерджится в `main`.** Файл живёт в feature-ветке вместе с `docs/<TICKET>/`.
- При откате фазы (например, после `QA_FAIL` → переделка → новый `IMPLEMENT_STEP_OK`) пишется новая строка с новой датой — старая остаётся.

## Доступность по уровням

| Уровень | `metrics.log` |
|---|---|
| Lite | Нет |
| Standard | Опционально |
| Enterprise | Обязательно |

См. [[Tier System]] для полного сравнения уровней.
