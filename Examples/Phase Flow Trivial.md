# Trivial Fast Path

> **Workflow Minor: 3.3** — пропорциональный путь для ограниченных
> низкорисковых задач. Канонические границы полосы — в
> [[../Methodology/Lanes]].

## Классификация и согласие

Агент предлагает Fast Path проактивно, объясняет, почему scope ограничен,
перечисляет пропускаемые и сохраняемые шаги и ждёт явного согласия владельца.
По умолчанию используется Professional.

Fast Path запрещён при Critical trigger, неоднозначном или растущем scope,
новой зависимости, schema/storage/public-contract изменении,
production/deployment или external-resource mutation. Любой обнаруженный
disqualifier останавливает работу до переклассификации.

## Компактный workspace

```text
docs/<TICKET>/
├── .active_ticket
├── idea-<TICKET>.md
├── tasklist-<TICKET>.md
└── review/
    └── <TICKET>-review.md
```

Phase/plan/PRD/research/vision/QA/security scaffolding не создаётся. Принятые
Idea, tasklist и batch proposal образуют baseline без отдельного specification
checkpoint.

## Выполнение и проверки

1. Выполнить один bounded batch.
2. Запустить все focused checks из tasklist.
3. Один раз успешно выполнить полный project gate до `REVIEW_OK`.
4. Создать единственный канонический `review/<TICKET>-review.md`.
5. Показать полный diff и sensitive-content review.

Если после review меняются функциональные или tooling-файлы, focused и полный
gate выполняются заново. Чистый archive/roadmap closeout использует только
formatting, full/quick validator, `git diff --check` и sensitive scan.

## Owner-visible delivery

1. **Delivery bundle:** точные commit message, branch, push target и draft PR.
2. **Closeout bundle:** marker-free archive transition, commit, push, CI и
   mark-ready.
3. **Merge/cleanup bundle:** запрашивается отдельно; squash merge, проверка
   `main` и post-merge CI, затем удаление только merged remote branch и снятие
   upstream при сохранении локальной ветки.

Каждый bundle перечисляет действия, targets, prerequisites и stop conditions.
Diff/identity/SHA/CI drift прекращает оставшиеся действия и требует нового
разрешения. Generic bundle никогда не разрешает инфраструктурную мутацию.

## Shipment

После draft PR marker удаляется, workspace переносится в
`docs/archive/<TICKET>/`, archive index и roadmap обновляются в том же primary
PR. Архив — историческое evidence; актуальные решения находятся в
`docs/project/`.

## Ссылки

- [[../Methodology/Lanes]] — eligibility и reclassification
- [[../Operations/Ship A Feature]] — primary-PR archive lifecycle
- [[Phase Flow Professional]] — стандартный полный поток
- [[Phase Flow Critical]] — поток с security review
