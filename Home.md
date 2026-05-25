# Enterprise Claude AIDD

Универсальная методология AI-Driven Development для Claude Code.
Спроектирована для сложных продуктов, где важны корректность, воспроизводимость и аудируемость.

---

## Быстрый старт

- [[Quickstart/Bootstrap New Project]] — настройка AIDD в новом проекте с нуля
- [[Quickstart/Adopt Existing Project]] — добавление AIDD в существующую кодовую базу
- [[Quickstart/First Session Checklist]] — проверка готовности рантайма
- [[Quickstart/Daily Command Map]] — справочная карточка команд оператора

## Методология

- [[Methodology/Overview]] — полный жизненный цикл, полосы, оптимизация токенов, ограничители
- [[Methodology/Lanes]] — Trivial, Professional, Critical — когда какую использовать
- [[Methodology/Roles And Gates]] — 7 ролей, 12 гейтов, владение артефактами
- [[Methodology/Artifact Contracts]] — один документ = одна ответственность
- [[Methodology/Token Optimization]] — техники эффективного использования контекста
- [[Methodology/Tier System]] — конфигурации Lite / Standard / Enterprise

## Операции

- [[Operations/Start A Feature]] — создание рабочего пространства, заполнение идеи, выбор полосы
- [[Operations/Prepare A Phase]] — конвейер analyst -> researcher -> planner
- [[Operations/Run A Professional Phase]] — цикл реализации на основе батчей
- [[Operations/Run A Critical Phase]] — реализация с усиленной безопасностью
- [[Operations/Review And QA Routing]] — гейты качества после реализации
- [[Operations/Ship A Feature]] — готовность к релизу и синхронизация документации
- [[Operations/Troubleshooting]] — типичные проблемы и их решения

## Рантайм

- [[Runtime/Hooks Map]] — все хуки Claude с назначением, режимом, оптимизацией
- [[Runtime/Skills Reference]] — все навыки `/aidd-*`
- [[Runtime/External Skills]] — внешние skill-паки Flutter/Dart и их интеграция в гейты
- [[Runtime/Agents Reference]] — 7 ролей агентов и их контракты
- [[Runtime/MCP Integration]] — детерминированный тулинг через MCP-серверы
- [[Runtime/Team Mode]] — когда и как включать мультиагентную оркестрацию

## Шаблоны

- [[Templates/Artifacts/]] — шаблоны артефактов, разворачиваемые в `docs/<TICKET>/`
- [[Templates/Runtime/]] — шаблоны конфигурации `.claude/`
- [[Templates/Project Docs/]] — заготовки для `docs/project/`
- `Templates/CLAUDE.md.template` — параметризованный `CLAUDE.md` проекта
- `Templates/AGENTS.md.template` — параметризованный `AGENTS.md` проекта

## Технические адаптеры

- [[Tech Adaptors/README]] — как создать новый адаптер
- [[Tech Adaptors/Flutter-Dart/]] — BLoC, Clean Architecture, Dart MCP

## Примеры

- [[Examples/Feature Workspace Structure]] — структура папок для фичи
- [[Examples/Phase Flow Professional]] — пошаговый разбор Professional-фазы
- [[Examples/Phase Flow Critical]] — пошаговый разбор Critical-фазы
- [[Examples/Tier Comparison]] — чем отличаются Lite, Standard, Enterprise

## Чеклисты

- [[Checklists/Start Feature]]
- [[Checklists/Prepare Phase]]
- [[Checklists/Implement Batch]]
- [[Checklists/Complete Phase Professional]]
- [[Checklists/Complete Phase Critical]]
- [[Checklists/Ship Feature]]
- [[Checklists/Verify Hooks]]

---

## Ключевые принципы

1. `docs/project/` хранит постоянную истину (конвенции, воркфлоу, стиль, ADR, шаблоны)
2. `docs/<TICKET>/` хранит временную память фичи (очищается перед мержем)
3. Claude-native рантайм живёт в `.claude/settings.json`, `.claude/agents/`, `.claude/skills/`, `.mcp.json`
4. Каждый документ владеет ровно одним типом знаний
5. Оптимизация токенов встроена в каждый слой (хуки, навыки, артефакты)

## Именование тикетов

Формат зависит от вашего трекера: `BW-0001`, `AG-2160`, `INGEST-42`, `#123`.
В этом хранилище `<TICKET>` используется как универсальный плейсхолдер.

## Версия воркфлоу

Текущая: **3**
Все артефакты содержат `Workflow Version: 3` в заголовках метаданных.
