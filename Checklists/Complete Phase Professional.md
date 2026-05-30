# Завершение Professional фазы

Используйте этот чек-лист при закрытии фазы на полосе Professional. Подробности в [[Operations/Run A Professional Phase]] и [[Operations/Review And QA Routing]].

## Реализация

- [ ] Все батчи выполнены
- [ ] Все проверки проходят (`/aidd-run-checks`)

## Review

- [ ] Reviewer вызван ([[Methodology/Roles And Gates#Reviewer]])
- [ ] Гейт `REVIEW_OK` пройден

## QA

- [ ] QA вызван ([[Methodology/Roles And Gates#QA]])
- [ ] Гейт `QA_PASS` пройден

## Docs sync

- [ ] Изменилось ли поведение, описанное в `docs/project/` (conventions, code-style, architecture, workflow, guidelines, ADR)? Если да — соответствующий файл `docs/project/` обновлён в этом же PR. (yes / no / N-A — зафиксировать в phase summary.)

## Закрытие фазы

- [ ] Summary создан (`<TICKET>-phase-N-summary.md`)
- [ ] `/aidd-complete-phase N`
- [ ] Фаза отмечена как DONE в tasklist
