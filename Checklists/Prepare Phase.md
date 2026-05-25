# Подготовка фазы

Используйте этот чек-лист перед началом реализации фазы. Подробности в [[Operations/Prepare A Phase]].

## Создание фазы

- [ ] Фаза создана: `/aidd-new-phase N`

## Артефакты подготовки

- [ ] PRD создан и заполнен аналитиком ([[Methodology/Roles And Gates#Analyst]])
- [ ] PRD содержит секцию `## Clarification round` (3-5 Q/A) ИЛИ стаб `### Considered and rejected` (>=3 рассмотренных-и-отвергнутых неоднозначностей)
- [ ] Spec-critic запущен против свежего PRD; создан артефакт `docs/<TICKET>/critique/<TICKET>-phase-<N>-critique.md` с минимум 3 findings
- [ ] Аналитик отработал блокирующие findings (если были) и флипнул Status PRD `PRD_READY -> SPEC_CRITIQUED`
- [ ] При вердикте `SPEC_BLOCKED` -- PRD переработан, spec-critic перезапущен, повторный вердикт `SPEC_CRITIQUED` получен
- [ ] Research выполнен (Standard+) ([[Methodology/Roles And Gates#Researcher]])
- [ ] Plan создан планировщиком ([[Methodology/Roles And Gates#Planner]])
- [ ] Brief сформирован (файл `phase/<TICKET>/phase-N.md`)

## Определение полосы

- [ ] Полоса определена (Professional / Critical)

## Гейты

- [ ] Гейт `PLAN_APPROVED` пройден
- [ ] Гейт `TASKLIST_READY` пройден
