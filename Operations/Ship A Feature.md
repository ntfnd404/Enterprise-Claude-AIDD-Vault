# Ship A Feature

## Чек-лист перед отправкой

Перед отправкой проверьте:
- Все саммари ревью фаз завершены
- Все QA-отчёты фаз завершены
- Все Critical-фазы имеют проверки безопасности
- Таск-лист полностью зелёный
- Валидатор зелёный: `/aidd-validate`
- Тикет ровно один раз находится в `In-flight` в project roadmap
- Все отложенные findings зарегистрированы как planned/deferred roadmap items

## Команда отправки

```text
/aidd-ship-feature
```

## Перед мержем

1. **Перенесите долговременные знания** в `docs/project/`:
   - Новые постоянные правила — `conventions.md`
   - Архитектурные решения — `docs/project/adr/`
   - Улучшения процесса — `workflow.md` или шаблоны
2. **Убедитесь**, что долговременная истина находится в `docs/project/`, а
   workspace готов стать marker-free историческим архивом
3. **Обновите** conventions, workflow или шаблоны, если фича изменила процессные знания
4. **Откройте primary PR как draft**, чтобы получить его номер, затем через
   `/aidd-ship-feature` удалите marker, перенесите workspace в
   `docs/archive/<TICKET>/`, обновите archive index и roadmap и доставьте это в
   том же PR

## Что переносить

- Новые постоянные правила
- Архитектурные решения (ADR)
- Переиспользуемые чек-листы
- Улучшения валидатора
- Обновления шаблонов
- Deferred work и carry-forwards в `docs/project/roadmap.md`

## Что НЕ переносить

- Локальные детали реализации фазы
- Разовые заметки QA
- Промежуточные гипотезы
- Заметки по отладке

## Trivial Fast Path

Trivial использует точный delivery bundle, затем marker-free closeout bundle.
Squash merge остаётся отдельным owner-visible решением. После подтверждённого
merge можно удалить только merged remote branch; локальная ветка сохраняется.

Professional/Critical сохраняют отдельные разрешения commit, push, PR и merge.
После merge `main` содержит `docs/archive/<TICKET>/`, но не активный
`docs/<TICKET>/`.
