# Superpowers Overlay

Superpowers — это optional Claude Code plugin для структурированной инженерной работы: brainstorming, TDD, systematic debugging, `/execute-plan`, subagent-driven development, code-reviewer и writing-skills.

Он не заменяет AIDD.

```text
/aidd-* = workflow и gates
dart-* / flutter-* = stack execution skills
Superpowers = general execution methodology
AIDD docs/vault = source of truth
```

## Доктрина

AIDD владеет жизненным циклом: roles, lanes, gates, artifacts, approval boundaries, review/security/QA routing.

Superpowers помогает исполнять работу внутри текущего gate, но не может:

- продвинуть `Status` артефакта;
- заменить PRD, research, plan, phase brief, tasklist, review, security review или QA report;
- обходить approval перед implementation batch;
- заменить reviewer, security-reviewer или qa;
- расширить scope фазы без обновления AIDD-артефактов.

## Приоритеты

При конфликте выигрывает проект:

1. `docs/project/conventions.md`
2. `docs/project/adr/*`
3. `docs/project/code-style-guide.md`
4. `docs/project/workflow.md`
5. AIDD roles/gates/artifacts
6. External skills/plugins, включая Superpowers

## Как использовать

| Возможность Superpowers | Где полезна в AIDD | Ограничение |
|---|---|---|
| `/brainstorming` | idea shaping, PRD clarification, discovery | Результат должен попасть в AIDD artifact; сам по себе не `PRD_READY` |
| Adversarial spec review | критика PRD/plan до реализации | Professional: рекомендуется; Critical: обязательно перед `PLAN_APPROVED` |
| TDD | implementation batch с проверяемым поведением | Особенно полезно для domain/application/BLoC/codec/gateway/regression; не обязательно для каждого UI/layout изменения |
| Systematic debugging | QA_FAIL, flaky tests, runtime bugs | Сначала root cause, потом fix; при смене предположений обновить docs |
| `/execute-plan` | исполнение approved batch | Только после `PLAN_APPROVED` или `TASKLIST_READY`; не исполнять всю фазу без checkpoint |
| code-reviewer | pre-review/self-check | Не `REVIEW_OK`; официальный reviewer gate сохраняется |
| subagents | параллельное research/review/test exploration | Не обходят role ownership; production code пишет implementer |
| writing-skills | улучшение AIDD или проектных skills | Workflow-critical changes требуют validation |

## Adversarial Spec Review

Мягкое правило без нового gate status:

- Professional lane: рекомендуется перед `PLAN_APPROVED`.
- Critical lane: обязательно перед `PLAN_APPROVED`.

Цель — найти противоречия, implicit assumptions, overscope, questionable tech choices и missing acceptance criteria до реализации.

## Checkpoint после Superpowers

Если Superpowers использовался в implementation batch, summary должен указать:

- какой approved batch выполнялся;
- какие `dart-*` / `flutter-*` skills были релевантны;
- какая возможность Superpowers использовалась;
- какие checks/tests подтверждают результат;
- docs-drift result: какие docs обновлены или почему update не нужен.

## Что нельзя делать

- Нельзя считать `/execute-plan` разрешением реализовать весь phase plan.
- Нельзя считать code-reviewer заменой reviewer agent.
- Нельзя переходить в QA в Critical lane без security-reviewer.
- Нельзя оставлять новое знание только в чате или коде, если оно меняет docs/project или phase artifacts.
