# Внедрение в существующий проект

## Цель

Добавить AIDD v3.2 в существующую кодовую базу с минимальным вмешательством.

## AIDD v3.2 baseline: апгрейд существующего проекта

Если в проекте уже стоит AIDD v3.0/v3.1, выполните перед основным аудитом:

1. Поднимите `Workflow Minor` до `3.4` в шапке проектного `CLAUDE.md` (поле `Workflow Version` остаётся `3`).
2. Добавьте `Workflow Minor: 3.4` в шапки уже существующих шаблонов под `docs/project/templates/` (idea, vision, phase_brief, phase_plan, phase_prd, phase_qa, phase_research, phase_security_review, phase_review, trivial_tasklist, trivial_review, tasklist, adr).
3. Создайте `docs/project/vision.md` и `docs/project/roadmap.md` из vault scaffolds (`Templates/Project Docs/vision.md`, `Templates/Project Docs/roadmap.md`), если их ещё нет.
4. Скопируйте `Templates/Artifacts/discovery.md` в `docs/project/templates/discovery.md`, если ранее этот шаблон в проекте отсутствовал.
5. Включите вызов spec-critic в существующий analyst-флоу: после написания PRD/Plan analyst запускает spec-critic как sub-agent и фиксирует findings в QA-артефакте фазы.
6. Обновите `aidd_validate.sh` тремя новыми проверками: `check_verifiable_ac`, `check_spec_critique`, `check_clarification_round`. Скрипт должен фейлиться, если фаза не содержит spec-critique-секции или verifiable AC-чеклиста.
7. Зафиксируйте принятие Trivial Fast Path: перенесите eligibility,
   compact-artifact, full-gate, owner-bundle и reclassification contract из
   `[[../Methodology/Lanes]]`.
8. Добавьте `docs/archive/README.md` и primary-PR archive lifecycle; завершённые
   workspace больше не удаляются и не остаются только в локальных ветках.
9. Сделайте Discovery опциональным артефактом: при наличии альтернатив используйте `docs/project/templates/discovery.md` (мирорится из `[[../Templates/Artifacts/discovery]]`).

## Workflow Minor 3.4: failure diagnosis

Для существующего AIDD-проекта обновление выполняется с просмотром diff, без
слепой перезаписи пользовательских runtime-файлов:

1. Скопируйте
   `Templates/Runtime/skills/aidd-diagnose-failure--SKILL.md` в
   `.claude/skills/aidd-diagnose-failure/SKILL.md`.
2. Сравните и перенесите изменения из канонических `implementer.md`, `qa.md`,
   `aidd-run-checks`, `aidd-complete-phase` и project workflow docs.
3. Сравните проектный `.claude/bin/aidd_validate.sh` с новой версией из Vault;
   обновите validator так, чтобы `aidd-diagnose-failure` входил в обязательный
   список workflow skills.
4. Поднимите `Workflow Minor` до `3.4` в runtime docs и project artifact
   templates, затем запустите `/aidd-validate`.

`/aidd-init --adopt` добавляет отсутствующий skill, но по контракту не
перезаписывает уже существующие роли, validator и docs; поэтому шаги сравнения
выше остаются обязательными.

## Шаг 0: Установка seed-скилла

Если в проекте ещё нет `.claude/skills/aidd-init/SKILL.md`, скопируйте его вручную:

```bash
mkdir -p .claude/skills/aidd-init

cp "<PATH_TO_VAULT>/Templates/Runtime/skills/aidd-init--SKILL.md" \
   .claude/skills/aidd-init/SKILL.md
```

> **Диагностика:** если `/aidd-init` не реагирует после установки — откройте новую сессию Claude Code (скиллы загружаются при старте сессии). Убедитесь, что файл существует: `ls .claude/skills/aidd-init/SKILL.md`.

## Шаг 1: Запуск аудита

```text
/aidd-init --adopt
```

Этот режим:
1. Сканирует наличие директории `.claude/`
2. Сканирует существующую структуру `docs/`
3. Сообщает, что уже есть и чего не хватает
4. Предлагает план миграции (что создать, что объединить)

## Шаг 2: Инкрементальное внедрение

На основе результатов аудита:

### Если `.claude/settings.json` уже существует
- Объединить хуки: добавить недостающие события, сохранить существующие
- Не перезаписывать пользовательские хуки

### Если агенты уже существуют
- Проверить формат frontmatter
- Добавить недостающих агентов (например `security-reviewer` при переходе на Standard)
- Сохранить пользовательские модификации агентов

### Если `docs/project/` уже существует
- Добавить недостающие шаблоны в `docs/project/templates/`
- Сохранить существующие `conventions.md`, `code-style-guide.md` и т.д.
- Добавить заголовки метаданных, если отсутствуют (`Workflow Version: 3`)

### Если конвенции существуют, но отличаются от адаптера
- Оставить существующие конвенции как есть
- Добавить наложение адаптера как секцию "Reference" внизу
- Позволить команде решить, что принять

## Шаг 3: Проверка

```text
/aidd-validate
```

Исправьте все обнаруженные пробелы.

## Шаг 4: Начало работы по воркфлоу

```text
/aidd-new-ticket <PREFIX>-0001
```

## Типичные сценарии

### В проекте есть `.claude/commands/` (старый формат)
Команды автоматически трактуются как навыки. Миграция не требуется.
По желанию можно перенести в директорию `.claude/skills/` для поддержки вспомогательных файлов.

### В проекте есть документация, но нет заголовков метаданных
Запустите `/aidd-validate` — команда сообщит об отсутствующих заголовках.
Добавьте заголовки `Status`, `Ticket`, `Phase`, `Lane`, `Workflow Version: 3`, `Owner`.

### В проекте используется другой набор агентов
Агенты AIDD добавляются аддитивно. Ваши существующие пользовательские агенты продолжают работать.
Навыки воркфлоу AIDD ссылаются только на 7 стандартных ролей.

### Повышение тира (например Lite -> Standard)
```text
/aidd-init --adopt --tier standard
```
Добавляет недостающих агентов (`researcher`, `security-reviewer`), навыки и хуки.

## Совместимость версий

Все артефакты содержат `Workflow Version: 3` в заголовках.
При развитии методологии валидатор проверяет совместимость версий.
Путь обновления документируется для каждого изменения версии.
