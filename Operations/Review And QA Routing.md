# Review And QA Routing

## Цель

Правильно маршрутизировать через независимые гейты качества после реализации.

## Предусловия

- Фаза закрыта через `/aidd-complete-phase`
- Проверки пройдены: `/aidd-run-checks`

## Маршрутизация

### Полоса Trivial

```text
ticket reviewer only
```

Создаётся ровно один `review/<TICKET>-review.md`; QA и security artifacts не
создаются. Повторный review обновляет тот же файл и фиксирует новый раунд.

### Полоса Professional

```text
reviewer → qa
```

### Полоса Critical

```text
reviewer → security-reviewer → qa
```


## Superpowers pre-review

Superpowers code-reviewer можно использовать до официального reviewer gate как self-check. Он помогает найти проблемы раньше, но не создает `REVIEW_OK` и не заменяет reviewer artifact.

В Critical lane Superpowers не заменяет security-reviewer и не разрешает переходить к QA при security blocker.

## Проверки качества (`/aidd-run-checks`)

Четыре проверки последовательно, остановка при первой ошибке:

1. **Format** — исходные файлы (только изменённые файлы, приоритет MCP)
2. **Analyze** — статический анализ (нулевая толерантность: фатальные предупреждения + info)
3. **Lint** — дополнительные правила (зависят от стека: DCM, ESLint и т.д.)
4. **Test** — модульные/интеграционные тесты (приоритет MCP)

Конкретные команды зависят от вашего Tech Adaptor. См. [[../Runtime/MCP Integration]].

## Ожидаемые артефакты

| Артефакт | Полоса |
|---|---|
| `review/<TICKET>-phase-N-review.md` | Все |
| `security/<TICKET>-phase-N-security.md` | Только Critical |
| `qa/<TICKET>-phase-N-qa.md` | Все (кроме Trivial) |

## Требования гейтов

| Гейт | Обязателен для |
|---|---|
| `REVIEW_OK` | Всегда |
| `SECURITY_REVIEW_OK` | Только Critical |
| `QA_PASS` | Всегда (кроме Trivial) |

## Перед отправкой

Запустите валидатор:

```text
/aidd-validate
```

## Далее

Когда все фазы зелёные, переходите к [[Ship A Feature]].
