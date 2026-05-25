# Роли и гейты

## Роли

### Analyst

Владеет **чем**: цели фазы, сценарии, критерии успеха, ограничения.
- Читает: idea
- Пишет: PRD
- Гейт: `IDEA_READY` → `PRD_READY`

### Researcher

Владеет **что есть сейчас**: факты кодовой базы, факты платформы, ограничения зависимостей, риски.
- Читает: idea, PRD, кодовую базу
- Пишет: research, обновления vision
- Гейт: `PRD_READY` → `RESEARCH_DONE` / `VISION_APPROVED`

### Planner

Владеет **как именно**: изменения файлов, интерфейсы, последовательность, крайние случаи, пакеты выполнения.
- Читает: vision, PRD, research
- Пишет: plan, phase brief, tasklist
- Гейт: `RESEARCH_DONE` → `PLAN_APPROVED` → `TASKLIST_READY`

### Implementer

Владеет **выполнением кода**: текущий пакет, проверки, обновления phase/tasklist.
- Читает: phase brief, plan, PRD, conventions, code style
- Пишет: исходный код, обновления phase, обновления tasklist
- Гейт: `TASKLIST_READY` → `IMPLEMENT_STEP_OK`

### Reviewer

Владеет **корректностью**: соответствие плану, регрессии, соблюдение конвенций.
- Читает: diff, plan, PRD, conventions
- Пишет: phase summary
- Гейт: `IMPLEMENT_STEP_OK` → `REVIEW_OK`

### Security Reviewer

**Только полоса Critical.** Владеет состоянием безопасности: обработка чувствительных данных, границы доверия, безопасность auth/crypto/storage.
- Читает: diff, plan, PRD, review summary
- Пишет: security review
- Гейт: `REVIEW_OK` → `SECURITY_REVIEW_OK`

### QA

Владеет **доказательствами**: позитивные сценарии, негативные/граничные случаи, ручные проверки, итоговый вердикт.
- Читает: PRD, phase, plan, review/security summaries
- Пишет: QA report
- Гейт: `REVIEW_OK` / `SECURITY_REVIEW_OK` → `QA_PASS`

## Гейты

| Гейт | Значение |
|---|---|
| `IDEA_READY` | Скоуп и намерение зафиксированы |
| `PRD_READY` | Требования фазы полны |
| `RESEARCH_DONE` | Факты кодовой базы и риски собраны |
| `VISION_APPROVED` | Архитектура фичи зафиксирована |
| `PLAN_APPROVED` | Реализация решена полностью |
| `TASKLIST_READY` | Implementer может начинать работу |
| `IMPLEMENT_STEP_OK` | Пакет завершён и проверки пройдены |
| `REVIEW_OK` | Reviewer не блокирует |
| `SECURITY_REVIEW_OK` | Гейт безопасности пройден (только Critical) |
| `QA_PASS` | Верификация завершена |
| `RELEASE_READY` | Готово к отправке |
| `DOCS_UPDATED` | Долгосрочные знания синхронизированы в `docs/project/` |

## Ключевое правило

**Implementer — основная роль с правом записи.** Все остальные роли работают преимущественно на чтение — они создают артефакты (PRD, research, plan, review, QA), но не изменяют исходный код.

## Владение артефактами

Подробнее см. [[Artifact Contracts]] — полный контракт того, что каждый артефакт должен и не должен содержать.

## Внешние skills на гейтах

Каждая роль может использовать внешние Flutter/Dart skill-паки внутри своего гейта без изменения контракта артефактов. Полная матрица: [[../Tech Adaptors/Flutter-Dart/gate-skill-matrix]]. Доктрина: [[../Runtime/External Skills]].

Правило: skill — это исполнитель внутри гейта, а не его замена. Гейт закрывает роль, не skill.
