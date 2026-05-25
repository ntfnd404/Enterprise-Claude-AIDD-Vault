# Tier Comparison

## Обзор

Одна и та же фича -- "Добавить экран пользовательских настроек" -- выглядит по-разному в зависимости от уровня (tier). Ниже показано, как каждый уровень влияет на процесс, артефакты, агентов и стоимость.

## Сравнение потоков

### Lite

```
idea → plan (включает research) → implement → review → qa
```

### Standard

```
idea → prd → research → vision → plan → implement → review → qa
```

### Enterprise

```
idea → prd → research → vision → plan → implement → review → [security review] → qa
```

## Агенты

| Агент | Lite | Standard | Enterprise |
|---|---|---|---|
| analyst | Есть | Есть | Есть |
| researcher | Нет (research включен в planner) | Есть | Есть |
| planner | Есть | Есть | Есть |
| implementer | Есть | Есть | Есть |
| reviewer | Есть | Есть | Есть |
| security-reviewer | Нет | Есть (только для Critical) | Есть (обязателен для Critical) |
| qa | Есть | Есть | Есть |
| Кастомные доменные агенты | Нет | Нет | Доступны |
| **Итого** | **5** | **7** | **7+** |

## Артефакты

| Артефакт | Lite | Standard | Enterprise |
|---|---|---|---|
| `.active_ticket` | Есть | Есть | Есть |
| `idea` | Есть | Есть | Есть |
| `vision` | Нет | Есть | Есть |
| `tasklist` | Есть | Есть | Есть |
| `prd` | Нет (в plan) | Есть | Есть |
| `research` | Нет (в plan) | Есть | Есть |
| `plan` | Есть (объединенный) | Есть | Есть |
| `brief` | Есть | Есть | Есть |
| `phase` | Есть | Есть | Есть |
| `summary` | Нет | Есть | Есть |
| `qa` | Есть | Есть | Есть |
| `security` | Нет | Только Critical | Обязателен для Critical |
| `adr` | Опционально | Опционально | Обязательно |
| `metrics.log` | Нет | Опционально | Обязательно |
| **На фазу** | **~4** | **~7** | **~7+** |

## Гейты

| Гейт | Lite | Standard | Enterprise |
|---|---|---|---|
| `IDEA_READY` | Есть | Есть | Есть |
| `PRD_APPROVED` | Нет | Есть | Есть |
| `RESEARCH_DONE` | Нет | Есть | Есть |
| `VISION_SET` | Нет | Есть | Есть |
| `PLAN_APPROVED` | Есть | Есть | Есть |
| `TASKLIST_READY` | Есть | Есть | Есть |
| `IMPLEMENT_STEP_OK` | Есть | Есть | Есть |
| `REVIEW_OK` | Есть | Есть | Есть |
| `SECURITY_REVIEW_OK` | Нет | Только Critical | Обязателен для Critical |
| `QA_PASS` | Есть | Есть | Есть |
| `PHASE_DONE` | Есть | Есть | Есть |
| Проверка прогрессии гейтов | Нет | Нет | Есть |
| **Модель** | **Упрощённая (6)** | **Полная (12)** | **Полная + расширенная** |

## Хуки

| Хук | Lite | Standard | Enterprise |
|---|---|---|---|
| InstructionsLoaded | Есть | Есть | Есть |
| PreToolUse (gate check) | Есть | Есть | Есть |
| PostToolUse (tech adaptor) | Есть | Есть | Есть |
| PostCompact | Есть | Есть | Есть |
| FileChanged | Есть | Есть | Есть |
| ConfigChange | Есть | Есть | Есть |
| SubagentStart | Нет | Есть | Есть |
| SubagentStop | Нет | Есть | Есть |
| PhaseTransition | Нет | Есть | Есть |
| MetricsLog | Нет | Есть | Есть |
| TaskCreated (team mode) | Нет | Нет | Есть |
| TaskCompleted (team mode) | Нет | Нет | Есть |
| **Итого** | **6** | **10** | **12** |

## Скиллы (команды)

| Скилл | Lite | Standard | Enterprise |
|---|---|---|---|
| `/aidd-init` | Есть | Есть | Есть |
| `/aidd-new-ticket` | Есть | Есть | Есть |
| `/aidd-start-phase` | Есть | Есть | Есть |
| `/aidd-run-checks` | Есть | Есть | Есть |
| `/aidd-ship-feature` | Есть | Есть | Есть |
| `/aidd-new-phase` | Нет | Есть | Есть |
| `/aidd-complete-phase` | Нет | Есть | Есть |
| `/aidd-validate` | Нет | Есть | Есть |
| **Итого** | **5** | **8** | **8+** |

## Полосы (Lanes)

| Полоса | Lite | Standard | Enterprise |
|---|---|---|---|
| Trivial | Нет | Нет | Есть |
| Professional | Есть (единственная) | Есть | Есть |
| Critical | Нет | Есть | Есть |

## Ориентировочное потребление токенов

| Аспект | Lite | Standard | Enterprise |
|---|---|---|---|
| Артефактов на фичу (2 фазы) | ~8 | ~14-18 | ~18+ |
| Агентов вызвано на фазу | 5 | 6-7 | 7+ |
| Контекст на фазу | Минимальный | Умеренный | Максимальный |
| Относительная стоимость | 1x | 2-3x | 3-5x |

Основной драйвер стоимости -- количество артефактов, которые агенты читают и пишут. В Lite planner объединяет research и plan, что экономит целый проход агента и несколько артефактов.

## Когда какой уровень использовать

| Ситуация | Рекомендация |
|---|---|
| Персональный проект, прототип | Lite |
| Продакшн-приложение, один разработчик | Standard |
| Продакшн-приложение, команда | Standard |
| Финтех, криптовалюты, регулируемые данные | Enterprise |
| Open-source библиотека | Lite или Standard |
| Enterprise SaaS | Standard или Enterprise |

## Повышение уровня

Уровни аддитивны. Повышение с Lite до Standard добавляет недостающих агентов, скиллы и хуки без нарушения текущей работы:

```text
/aidd-init --adopt --tier standard
```

Повышение с Standard до Enterprise:

```text
/aidd-init --adopt --tier enterprise
```

Понижение уровня не поддерживается -- лишние компоненты безопасно игнорируются при ручном возврате, но автоматического механизма нет.

## Ссылки

- [[../Methodology/Tier System]] -- полное описание системы уровней
- [[../Methodology/Lanes]] -- определение полос
- [[Feature Workspace Structure]] -- структура рабочего пространства по уровням
- [[Phase Flow Professional]] -- пример потока Professional
- [[Phase Flow Critical]] -- пример потока Critical
