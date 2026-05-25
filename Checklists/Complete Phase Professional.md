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

## Закрытие фазы

- [ ] Summary создан (`<TICKET>-phase-N-summary.md`)
- [ ] `/aidd-complete-phase N`
- [ ] Фаза отмечена как DONE в tasklist
