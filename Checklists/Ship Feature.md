# Отправка фичи

Используйте этот чек-лист перед мержем фичи в основную ветку. Подробности в [[Operations/Ship A Feature]].

## Проверка готовности

- [ ] Все фазы завершены
- [ ] `/aidd-validate` пройден
- [ ] Документация синхронизирована (долгосрочные знания перенесены в `docs/project/`)
- [ ] Все гейты всех фаз пройдены

## Отправка

- [ ] `/aidd-ship-feature`
- [ ] PR создан

## Контроль артефактов

- [ ] Долговременные решения перенесены в `docs/project/`
- [ ] `.active_ticket` удалён
- [ ] Workspace перенесён в `docs/archive/<TICKET>/`
- [ ] Archive index и roadmap обновлены в том же primary PR
- [ ] Архив не содержит credentials, private keys, personal email, raw SQL
      dumps или private response bodies
