# hhbp-claude-code

[English](README.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · **Русский** · [日本語](README.ja.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [한국어](README.ko.md)

Heshuo Harness Best Practices — плагин для Claude Code с хуками, агентами и навыками (skills) в соответствии со стандартами DDD для разработки микросервисов на Java и Maven.

## Обзор

`hhbp-claude-code` — это плагин для [Claude Code](https://claude.ai/code), который обеспечивает соблюдение инженерных практик производственного уровня в ваших сессиях разработки. Он объединяет:

- **Автоматический контроль качества кода** — форматирует Java-файлы при сохранении и следит за соблюдением соглашений о коммитах git
- **Предметно-ориентированные навыки** — готовые рабочие процессы для генерации кода, анализа SQL, создания каркаса API и проверки безопасности в соответствии с архитектурой DDD

Репозиторий: <https://github.com/rabbit4431/hhbp-claude-code>

## Возможности

- **3 хука** — SessionStart применяет выбранный язык; PreToolUse блокирует опасные команды оболочки; PostToolUse следит за соблюдением соглашений о коммитах git
- **22 навыка**
  - *Рабочий процесс для функциональности в нескольких сервисах* — `/springboot-feature-bootstrap` управляет цепочкой из 9 фаз: `/service-discovery`, `/feature-workspace-setup`, `/contract-first-design`, `/parallel-implementation`, `/multi-service-integration-test`, `/cross-service-review`, `/multi-branch-merge`, `/feature-cleanup`
  - *Основа* — `/test-driven-development`, `/writing-implementation-plan`, `/subagent-task-execution`, `/code-review-request`, `/finishing-a-feature-branch`, `/security-review`, `/docs-lookup`, `/language-setup`
  - *Генерация кода и SQL* — `/generate-api`, `/generate-code`, `/remove-unused-class`, `/sql-analyze`, `/slow-sql-optimize`
- **6 специализированных субагентов** — planner, java-reviewer, java-build-resolver, security-reviewer, sql-performance-reviewer, docs-lookup
- **3 LSP-сервера** — jdtls (Java), Pyright (Python) и typescript-language-server (TS/JS) для перехода к определению, поиска ссылок, подсказок при наведении и диагностики
- **Конфигурация MCP** — преднастроенные параметры MCP-серверов в `common/mcp/`
- **Стандарты разработки** — спецификация архитектуры DDD и стандарты backend-разработки в `spec/`
- **Выбор языка** — ответы, планы, отчёты, описания коммитов и комментарии в коде на 8 языках: английском, французском, немецком, русском, японском, упрощённом китайском, традиционном китайском и корейском

## Структура каталогов

```
hhbp-claude-code/
├── agents/                     # Subagent definitions (planner, java-reviewer, security-reviewer, …)
└── common/                     # shared content (vendored via git subtree from hhbp-common)
    ├── hooks/
    │   └── hooks.json          # Claude Code hook registrations (SessionStart / PreToolUse / PostToolUse)
    ├── skills/                 # Skill definitions (generate-code, generate-api, sql-analyze, …)
    ├── scripts/
    │   └── hooks/              # Hook scripts (language, block-dangerous, git-workflow) + locales/
    ├── mcp/
    │   └── mcp.json            # MCP server configuration (context7)
    ├── lsp/
    │   └── lsp.json            # LSP server configuration (jdtls, pyright, typescript)
    └── spec/                   # Architecture and coding standards docs
```

## Установка

```
/plugin marketplace add rabbit4431/hhbp-claude-code

/plugin install hhbp-claude-code@hhbp-claude-code
```

## Язык

При включении плагина Claude Code запрашивает **язык** (*Language*):

| Код | Язык |
|---|---|
| `en` | English (по умолчанию) |
| `fr` | Français |
| `de` | Deutsch |
| `ru` | Русский |
| `ja` | 日本語 |
| `zh-CN` | 简体中文 |
| `zh-TW` | 繁體中文 |
| `ko` | 한국어 |

После этого Claude отвечает на выбранном языке и пишет на нём планы, ревью, отчёты, описания коммитов и комментарии в коде. Идентификаторы в коде, имена файлов, команды, префикс коммита `<type>:` и токены протокола рабочего процесса (`feature-state.json`, вердикты `REVIEW.md`) остаются на английском, чтобы навыки продолжали работать. Сообщения о заблокированных командах тоже переводятся.

Чтобы изменить язык позже: `/plugin` → **Installed** → **hhbp-claude-code** → **Configure options** или `/config`. Новый язык применяется со следующей сессии.

> **Требуется Claude Code v2.1.271 или новее** — выбор языка использует `options` в `userConfig`,
> которые более старые версии загрузить не могут.

Навыки, агенты и спецификации написаны на английском; настройка языка влияет только на вывод.

## Обновление common

`common/` встроен из [hhbp-common](https://github.com/rabbit4431/hhbp-common)
с помощью git subtree. Чтобы получить последнюю версию общего содержимого:

```
# one-time: register the upstream remote
git remote add common https://github.com/rabbit4431/hhbp-common.git

# pull the latest common content into the common/ subtree
git subtree pull --prefix=common common main --squash
```

## Модели

Каждый навык закрепляет свою модель во frontmatter файла `SKILL.md` (`model:`), и Claude Code автоматически переключается на неё, пока навык активен, — в том числе при каждом переходе между фазами рабочего процесса `springboot-feature-bootstrap` (см. «Model selection» в `common/skills/springboot-feature-bootstrap/references/phase-dispatcher.md`).

| Уровень | Модель | Навыки |
|---|---|---|
| design | `claude-opus-5-5` | service-discovery, contract-first-design, writing-implementation-plan, cross-service-review, code-review-request, security-review |
| impl | `claude-sonnet-5-5` | generate-api, generate-code, test-driven-development, parallel-implementation, subagent-task-execution, multi-service-integration-test, remove-unused-class, springboot-feature-bootstrap, feature-workspace-setup, multi-branch-merge, finishing-a-feature-branch, feature-cleanup, docs-lookup, language-setup |

`sql-analyze` и `slow-sql-optimize` используют модель сессии. Смена модели навыком действует до конца хода и игнорируется (остаётся модель сессии), если список `availableModels` вашей организации её не включает. Субагенты в `agents/` сохраняют собственную настройку `model:`.

Frontmatter `model:` поддерживается только в Claude Code: родственный плагин для Codex,
[hhbp-codex](https://github.com/rabbit4431/hhbp-codex), игнорирует его и запускает каждый навык на модели сессии.

## Справочник по хукам

| Событие | Matcher | Скрипт | Назначение |
|---|---|---|---|
| SessionStart | `startup\|resume\|clear\|compact` | `language.js` | Сообщить Claude, на каком языке выводить результат |
| PreToolUse | `Bash` | `block-dangerous.js` | Блокировать опасные команды оболочки до их выполнения |
| PostToolUse | `Write\|Edit\|MultiEdit` | `git-workflow.js` | Следить за правилами времени и формата коммитов |

## Справочник по LSP

Языковые серверы дают Claude анализ кода в реальном времени (переход к определению, поиск ссылок, подсказки при наведении, диагностика) через инструмент `LSP`. Они настраиваются в `common/lsp/lsp.json` и регистрируются через поле `lspServers` манифеста плагина.

| Сервер | Язык(и) | Команда | Установка |
|---|---|---|---|
| `jdtls` | Java | `jdtls` | `brew install jdtls` (или [eclipse.jdt.ls](https://github.com/eclipse-jdtls/eclipse.jdt.ls)) |
| `pyright` | Python | `pyright-langserver --stdio` | `npm i -g pyright` (или `pip install pyright`) |
| `typescript` | TS / TSX / JS / JSX | `typescript-language-server --stdio` | `npm i -g typescript-language-server typescript` |

> **Предварительное требование:** плагин лишь настраивает подключение Claude Code к языковому
> серверу — бинарные файлы в него **не входят**. Установите перечисленные серверы самостоятельно.
> Отсутствующий бинарный файл отображается как `Executable not found in $PATH` на вкладке Errors
> в `/plugin`; после установки выполните `/reload-plugins`.
