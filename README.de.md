# hhbp-claude-code

[English](README.md) · [Français](README.fr.md) · **Deutsch** · [Русский](README.ru.md) · [日本語](README.ja.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [한국어](README.ko.md)

Heshuo Harness Best Practices — Claude-Code-Plugin mit DDD-konformen Hooks, Agents und Skills für die Entwicklung von Java-Maven-Microservices.

## Überblick

`hhbp-claude-code` ist ein [Claude Code](https://claude.ai/code)-Plugin, das produktionsreife Engineering-Praktiken in Ihren Entwicklungssitzungen durchsetzt. Es vereint:

- **Automatisierte Codequalität** — formatiert Java-Dateien beim Speichern und setzt Git-Commit-Konventionen durch
- **Domänengetriebene Skills** — fertige Workflows für Codegenerierung, SQL-Analyse, API-Gerüste und Sicherheitsreviews, ausgerichtet an der DDD-Architektur

Repository: <https://github.com/rabbit4431/hhbp-claude-code>

## Funktionen

- **3 Hooks** — SessionStart wendet die gewählte Sprache an; PreToolUse blockiert gefährliche Shell-Befehle; PostToolUse setzt Git-Commit-Konventionen durch
- **22 Skills**
  - *Multi-Service-Feature-Workflow* — `/springboot-feature-bootstrap` orchestriert die 9-phasige Kette: `/service-discovery`, `/feature-workspace-setup`, `/contract-first-design`, `/parallel-implementation`, `/multi-service-integration-test`, `/cross-service-review`, `/multi-branch-merge`, `/feature-cleanup`
  - *Grundlagen* — `/test-driven-development`, `/writing-implementation-plan`, `/subagent-task-execution`, `/code-review-request`, `/finishing-a-feature-branch`, `/security-review`, `/docs-lookup`, `/language-setup`
  - *Codegenerierung & SQL* — `/generate-api`, `/generate-code`, `/remove-unused-class`, `/sql-analyze`, `/slow-sql-optimize`
- **6 spezialisierte Subagents** — planner, java-reviewer, java-build-resolver, security-reviewer, sql-performance-reviewer, docs-lookup
- **3 LSP-Server** — jdtls (Java), Pyright (Python) und typescript-language-server (TS/JS) für Go-to-Definition, Find-References, Hover und Diagnosen
- **MCP-Konfiguration** — vorkonfigurierte MCP-Server-Einstellungen in `common/mcp/`
- **Entwicklungsstandards** — DDD-Architekturspezifikation und Backend-Entwicklungsstandards in `spec/`
- **Sprachauswahl** — Antworten, Pläne, Berichte, Commit-Beschreibungen und Codekommentare in 8 Sprachen: Englisch, Französisch, Deutsch, Russisch, Japanisch, vereinfachtes Chinesisch, traditionelles Chinesisch und Koreanisch

## Verzeichnisstruktur

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

## Installation

```
/plugin marketplace add rabbit4431/hhbp-claude-code

/plugin install hhbp-claude-code@hhbp-claude-code
```

## Sprache

Wenn Sie das Plugin aktivieren, fragt Claude Code nach einer **Sprache** (*Language*):

| Code | Sprache |
|---|---|
| `en` | English (Standard) |
| `fr` | Français |
| `de` | Deutsch |
| `ru` | Русский |
| `ja` | 日本語 |
| `zh-CN` | 简体中文 |
| `zh-TW` | 繁體中文 |
| `ko` | 한국어 |

Claude antwortet dann in dieser Sprache und verfasst darin auch Pläne, Reviews, Berichte, Commit-Beschreibungen und Codekommentare. Code-Bezeichner, Dateinamen, Befehle, das Commit-Präfix `<type>:` und die Tokens des Workflow-Protokolls (`feature-state.json`, `REVIEW.md`-Urteile) bleiben auf Englisch, damit die Skills weiterhin funktionieren. Meldungen zu blockierten Befehlen werden ebenfalls übersetzt.

Später ändern: `/plugin` → **Installed** → **hhbp-claude-code** → **Configure options** oder `/config`. Die neue Sprache gilt ab der nächsten Sitzung.

> **Erfordert Claude Code v2.1.271 oder neuer** — die Sprachauswahl nutzt `userConfig`-`options`,
> die ältere Versionen nicht laden können.

Skills, Agents und Spezifikationen sind auf Englisch verfasst; die Spracheinstellung betrifft nur die Ausgabe.

## common aktualisieren

`common/` wird aus [hhbp-common](https://github.com/rabbit4431/hhbp-common)
per git subtree eingebunden. So holen Sie die neuesten gemeinsamen Inhalte:

```
# one-time: register the upstream remote
git remote add common https://github.com/rabbit4431/hhbp-common.git

# pull the latest common content into the common/ subtree
git subtree pull --prefix=common common main --squash
```

## Modelle

Jeder Skill legt sein Modell im Frontmatter von `SKILL.md` fest (`model:`), und Claude Code wechselt automatisch zu diesem Modell, solange der Skill aktiv ist — auch bei jedem Phasenübergang des Workflows `springboot-feature-bootstrap` (siehe „Model selection“ in `common/skills/springboot-feature-bootstrap/references/phase-dispatcher.md`).

| Stufe | Modell | Skills |
|---|---|---|
| design | `claude-opus-5-5` | service-discovery, contract-first-design, writing-implementation-plan, cross-service-review, code-review-request, security-review |
| impl | `claude-sonnet-5-5` | generate-api, generate-code, test-driven-development, parallel-implementation, subagent-task-execution, multi-service-integration-test, remove-unused-class, springboot-feature-bootstrap, feature-workspace-setup, multi-branch-merge, finishing-a-feature-branch, feature-cleanup, docs-lookup, language-setup |

`sql-analyze` und `slow-sql-optimize` behalten das Sitzungsmodell. Der Modellwechsel eines Skills gilt bis zum Ende des Turns und wird ignoriert (das Sitzungsmodell bleibt), wenn die `availableModels`-Allowlist Ihrer Organisation das Modell ausschließt. Die Subagents in `agents/` behalten ihre eigene `model:`-Einstellung.

Das `model:`-Frontmatter gilt nur für Claude Code: das Codex-Schwesterplugin
[hhbp-codex](https://github.com/rabbit4431/hhbp-codex) ignoriert es und führt jeden Skill mit dem Sitzungsmodell aus.

## Hook-Referenz

| Ereignis | Matcher | Skript | Zweck |
|---|---|---|---|
| SessionStart | `startup\|resume\|clear\|compact` | `language.js` | Claude mitteilen, in welcher Sprache ausgegeben wird |
| PreToolUse | `Bash` | `block-dangerous.js` | Gefährliche Shell-Befehle vor der Ausführung blockieren |
| PostToolUse | `Write\|Edit\|MultiEdit` | `git-workflow.js` | Regeln für Commit-Zeitpunkt und -Format durchsetzen |

## LSP-Referenz

Language Server geben Claude über das Tool `LSP` Code-Intelligenz in Echtzeit (Go-to-Definition, Find-References, Hover, Diagnosen). Sie werden in `common/lsp/lsp.json` konfiguriert und über das Feld `lspServers` des Plugin-Manifests registriert.

| Server | Sprache(n) | Befehl | Installation |
|---|---|---|---|
| `jdtls` | Java | `jdtls` | `brew install jdtls` (oder [eclipse.jdt.ls](https://github.com/eclipse-jdtls/eclipse.jdt.ls)) |
| `pyright` | Python | `pyright-langserver --stdio` | `npm i -g pyright` (oder `pip install pyright`) |
| `typescript` | TS / TSX / JS / JSX | `typescript-language-server --stdio` | `npm i -g typescript-language-server typescript` |

> **Voraussetzung:** Das Plugin konfiguriert nur, wie Claude Code sich mit einem Language Server
> verbindet — es liefert die Binärdateien **nicht** mit. Installieren Sie die obigen Server selbst.
> Eine fehlende Binärdatei erscheint als `Executable not found in $PATH` im Errors-Tab von `/plugin`;
> führen Sie nach der Installation `/reload-plugins` aus.
