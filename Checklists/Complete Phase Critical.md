# Завершение Critical фазы

Используйте этот чек-лист при закрытии фазы на полосе Critical. Включает все шаги Professional плюс проверку безопасности. Подробности в [[Operations/Run A Critical Phase]] и [[Operations/Review And QA Routing]].

## Все шаги Professional

- [ ] Все батчи выполнены
- [ ] Все проверки проходят (`/aidd-run-checks`)
- [ ] Reviewer вызван ([[Methodology/Roles And Gates#Reviewer]])
- [ ] Гейт `REVIEW_OK` пройден

## Проверка безопасности

- [ ] Security-reviewer вызван ([[Methodology/Roles And Gates#Security Reviewer]])
- [ ] Security review артефакт создан (`security/<TICKET>-phase-N.md`)
- [ ] Гейт `SECURITY_REVIEW_OK` пройден

## QA после security review

- [ ] QA вызван повторно после security review ([[Methodology/Roles And Gates#QA]])
- [ ] Все гейты пройдены (`REVIEW_OK`, `SECURITY_REVIEW_OK`, `QA_PASS`)

## Закрытие фазы

- [ ] `/aidd-complete-phase N`
- [ ] Фаза отмечена как DONE в tasklist
