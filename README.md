# hhbp-claude-code

**English** · [Français](README.fr.md) · [Deutsch](README.de.md) · [Русский](README.ru.md) · [日本語](README.ja.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [한국어](README.ko.md)

Heshuo Harness Best Practices — Claude Code plugin providing DDD-standard hooks, agents, and skills for Java Maven microservices development.

## Overview

`hhbp-claude-code` is a [Claude Code](https://claude.ai/code) plugin that enforces production-grade engineering practices across your development sessions. It brings together:

- **Automated code quality** — formats Java files on save and enforces git commit conventions
- **Domain-driven skills** — ready-made workflows for code generation, SQL analysis, API scaffolding, and security review aligned with DDD architecture

Repository: <https://github.com/rabbit4431/hhbp-claude-code>

## Features

- **3 hooks** — SessionStart applies your chosen language; PreToolUse blocks dangerous shell commands; PostToolUse enforces git commit conventions
- **22 skills**
  - *Multi-service feature workflow* — `/springboot-feature-bootstrap` orchestrates the 9-phase chain: `/service-discovery`, `/feature-workspace-setup`, `/contract-first-design`, `/parallel-implementation`, `/multi-service-integration-test`, `/cross-service-review`, `/multi-branch-merge`, `/feature-cleanup`
  - *Foundation* — `/test-driven-development`, `/writing-implementation-plan`, `/subagent-task-execution`, `/code-review-request`, `/finishing-a-feature-branch`, `/security-review`, `/docs-lookup`, `/language-setup`
  - *Codegen & SQL* — `/generate-api`, `/generate-code`, `/remove-unused-class`, `/sql-analyze`, `/slow-sql-optimize`
- **6 specialized subagents** — planner, java-reviewer, java-build-resolver, security-reviewer, sql-performance-reviewer, docs-lookup
- **3 LSP servers** — jdtls (Java), Pyright (Python), and typescript-language-server (TS/JS) for go-to-definition, find-references, hover, and diagnostics
- **MCP configuration** — pre-configured MCP server settings in `common/mcp/`
- **Development standards** — DDD architecture spec and backend development standards in `spec/`
- **Language selection** — replies, plans, reports, commit message descriptions, and code comments in 8 languages: English, French, German, Russian, Japanese, Simplified Chinese, Traditional Chinese, and Korean

## Directory Structure

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

## Language

When you enable the plugin, Claude Code asks for a **Language**:

| Code | Language |
|---|---|
| `en` | English (default) |
| `fr` | Français |
| `de` | Deutsch |
| `ru` | Русский |
| `ja` | 日本語 |
| `zh-CN` | 简体中文 |
| `zh-TW` | 繁體中文 |
| `ko` | 한국어 |

Claude then replies, and writes plans, reviews, reports, commit message descriptions, and code
comments, in that language. Code identifiers, file names, commands, the commit `<type>:` prefix,
and workflow protocol tokens (`feature-state.json`, `REVIEW.md` verdicts) stay in English so the
skills keep working. Blocked-command messages are translated too.

To change it later: `/plugin` → **Installed** → **hhbp-claude-code** → **Configure options**, or
`/config`. The new language applies from the next session.

> **Requires Claude Code v2.1.271 or later** — the language picker uses `userConfig` `options`,
> which older versions cannot load.

Skills, agents, and specs are written in English; the language setting controls output only.

## Updating common

`common/` is vendored from [hhbp-common](https://github.com/rabbit4431/hhbp-common)
via git subtree. To pull the latest shared content:

```
# one-time: register the upstream remote
git remote add common https://github.com/rabbit4431/hhbp-common.git

# pull the latest common content into the common/ subtree
git subtree pull --prefix=common common main --squash
```

## Models

Each skill pins its model in `SKILL.md` frontmatter (`model:`), and Claude Code switches to it
automatically while the skill is active — including at every phase transition of the
`springboot-feature-bootstrap` workflow (see "Model selection" in
`common/skills/springboot-feature-bootstrap/references/phase-dispatcher.md`).

| Tier | Model | Skills |
|---|---|---|
| design | `claude-opus-5-5` | service-discovery, contract-first-design, writing-implementation-plan, cross-service-review, code-review-request, security-review |
| impl | `claude-sonnet-5-5` | generate-api, generate-code, test-driven-development, parallel-implementation, subagent-task-execution, multi-service-integration-test, remove-unused-class, springboot-feature-bootstrap, feature-workspace-setup, multi-branch-merge, finishing-a-feature-branch, feature-cleanup, docs-lookup, language-setup |

`sql-analyze` and `slow-sql-optimize` keep the session model. A skill's model override lasts for
the rest of the turn, and is ignored (the session model stays) if your organization's
`availableModels` allowlist excludes it. The subagents in `agents/` keep their own `model:` setting.

The `model:` frontmatter is Claude Code–only: the Codex sibling,
[hhbp-codex](https://github.com/rabbit4431/hhbp-codex), ignores it and runs every skill on the
session model.

## Hooks Reference

| Event | Matcher | Script | Purpose |
|---|---|---|---|
| SessionStart | `startup\|resume\|clear\|compact` | `language.js` | Tell Claude which language to use for output |
| PreToolUse | `Bash` | `block-dangerous.js` | Block dangerous shell commands before execution |
| PostToolUse | `Write\|Edit\|MultiEdit` | `git-workflow.js` | Enforce commit timing and format rules |

## LSP Reference

Language servers give Claude real-time code intelligence (go-to-definition, find-references,
hover, diagnostics) via the `LSP` tool. Configured in `common/lsp/lsp.json` and registered
through the plugin manifest's `lspServers` field.

| Server | Language(s) | Command | Install |
|---|---|---|---|
| `jdtls` | Java | `jdtls` | `brew install jdtls` (or [eclipse.jdt.ls](https://github.com/eclipse-jdtls/eclipse.jdt.ls)) |
| `pyright` | Python | `pyright-langserver --stdio` | `npm i -g pyright` (or `pip install pyright`) |
| `typescript` | TS / TSX / JS / JSX | `typescript-language-server --stdio` | `npm i -g typescript-language-server typescript` |

> **Prerequisite:** the plugin only configures how Claude Code connects to a language
> server — it does **not** bundle the binaries. Install the servers above yourself. A missing
> binary shows as `Executable not found in $PATH` under the `/plugin` Errors tab; run
> `/reload-plugins` after installing.
