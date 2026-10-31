# hhbp-claude-code

[English](README.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Русский](README.ru.md) · [日本語](README.ja.md) · **简体中文** · [繁體中文](README.zh-TW.md) · [한국어](README.ko.md)

Heshuo Harness Best Practices —— 面向 Java Maven 微服务开发的 Claude Code 插件，提供符合 DDD 规范的钩子（hooks）、代理（agents）和技能（skills）。

## 概述

`hhbp-claude-code` 是一个 [Claude Code](https://claude.ai/code) 插件，在整个开发会话中贯彻生产级的工程实践。它包含：

- **自动化代码质量** —— 保存时格式化 Java 文件，并强制执行 git 提交规范
- **领域驱动的技能** —— 开箱即用的工作流，涵盖代码生成、SQL 分析、API 脚手架和安全审查，均与 DDD 架构保持一致

仓库：<https://github.com/rabbit4431/hhbp-claude-code>

## 功能

- **3 个钩子** —— SessionStart 应用你选择的语言；PreToolUse 拦截危险的 shell 命令；PostToolUse 强制执行 git 提交规范
- **22 个技能**
  - *多服务功能工作流* —— `/springboot-feature-bootstrap` 编排 9 个阶段的链路：`/service-discovery`、`/feature-workspace-setup`、`/contract-first-design`、`/parallel-implementation`、`/multi-service-integration-test`、`/cross-service-review`、`/multi-branch-merge`、`/feature-cleanup`
  - *基础* —— `/test-driven-development`、`/writing-implementation-plan`、`/subagent-task-execution`、`/code-review-request`、`/finishing-a-feature-branch`、`/security-review`、`/docs-lookup`、`/language-setup`
  - *代码生成与 SQL* —— `/generate-api`、`/generate-code`、`/remove-unused-class`、`/sql-analyze`、`/slow-sql-optimize`
- **6 个专用子代理** —— planner、java-reviewer、java-build-resolver、security-reviewer、sql-performance-reviewer、docs-lookup
- **3 个 LSP 服务器** —— jdtls（Java）、Pyright（Python）和 typescript-language-server（TS/JS），支持跳转到定义、查找引用、悬停提示和诊断
- **MCP 配置** —— `common/mcp/` 中预置的 MCP 服务器配置
- **开发规范** —— `spec/` 中的 DDD 架构规范和后端开发规范
- **语言选择** —— 回复、计划、报告、提交信息描述和代码注释支持 8 种语言：英语、法语、德语、俄语、日语、简体中文、繁体中文和韩语

## 目录结构

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

## 安装

```
/plugin marketplace add rabbit4431/hhbp-claude-code

/plugin install hhbp-claude-code@hhbp-claude-code
```

## 语言

启用插件时，Claude Code 会让你选择 **语言**（*Language*）：

| 代码 | 语言 |
|---|---|
| `en` | English（默认） |
| `fr` | Français |
| `de` | Deutsch |
| `ru` | Русский |
| `ja` | 日本語 |
| `zh-CN` | 简体中文 |
| `zh-TW` | 繁體中文 |
| `ko` | 한국어 |

之后 Claude 会用该语言回复，并用它撰写计划、评审、报告、提交信息描述和代码注释。代码标识符、文件名、命令、提交前缀 `<type>:` 以及工作流协议中的标记（`feature-state.json`、`REVIEW.md` 的结论）保持英文，以确保各技能正常运行。被拦截命令的提示信息也会被翻译。

之后如需更改：`/plugin` → **Installed** → **hhbp-claude-code** → **Configure options**，或使用 `/config`。新语言从下一个会话开始生效。

> **需要 Claude Code v2.1.271 或更高版本** —— 语言选择使用了 `userConfig` 的 `options`，
> 更早的版本无法加载该插件。

技能、代理和规范文档均以英文编写；语言设置只影响输出。

## 更新 common

`common/` 通过 git subtree 从 [hhbp-common](https://github.com/rabbit4431/hhbp-common)
引入。拉取最新的共享内容：

```
# one-time: register the upstream remote
git remote add common https://github.com/rabbit4431/hhbp-common.git

# pull the latest common content into the common/ subtree
git subtree pull --prefix=common common main --squash
```

## 模型

每个技能在 `SKILL.md` 的 frontmatter（`model:`）中固定所用模型，技能激活期间 Claude Code 会自动切换到该模型——包括 `springboot-feature-bootstrap` 工作流的每次阶段切换（参见 `common/skills/springboot-feature-bootstrap/references/phase-dispatcher.md` 中的 “Model selection”）。

| 层级 | 模型 | 技能 |
|---|---|---|
| design | `claude-opus-5-5` | service-discovery, contract-first-design, writing-implementation-plan, cross-service-review, code-review-request, security-review |
| impl | `claude-sonnet-5-5` | generate-api, generate-code, test-driven-development, parallel-implementation, subagent-task-execution, multi-service-integration-test, remove-unused-class, springboot-feature-bootstrap, feature-workspace-setup, multi-branch-merge, finishing-a-feature-branch, feature-cleanup, docs-lookup, language-setup |

`sql-analyze` 和 `slow-sql-optimize` 沿用会话模型。技能的模型切换在本轮结束前有效；如果组织的 `availableModels` 允许列表不包含该模型，则会被忽略（继续使用会话模型）。`agents/` 中的子代理保留各自的 `model:` 设置。

`model:` frontmatter 仅适用于 Claude Code：Codex 版的姊妹插件
[hhbp-codex](https://github.com/rabbit4431/hhbp-codex) 会忽略它，所有技能都使用会话模型运行。

## 钩子参考

| 事件 | Matcher | 脚本 | 用途 |
|---|---|---|---|
| SessionStart | `startup\|resume\|clear\|compact` | `language.js` | 告诉 Claude 输出使用哪种语言 |
| PreToolUse | `Bash` | `block-dangerous.js` | 在执行前拦截危险的 shell 命令 |
| PostToolUse | `Write\|Edit\|MultiEdit` | `git-workflow.js` | 强制执行提交时机和格式规则 |

## LSP 参考

语言服务器通过 `LSP` 工具为 Claude 提供实时的代码智能（跳转到定义、查找引用、悬停提示、诊断）。它们在 `common/lsp/lsp.json` 中配置，并通过插件清单的 `lspServers` 字段注册。

| 服务器 | 语言 | 命令 | 安装 |
|---|---|---|---|
| `jdtls` | Java | `jdtls` | `brew install jdtls`（或 [eclipse.jdt.ls](https://github.com/eclipse-jdtls/eclipse.jdt.ls)） |
| `pyright` | Python | `pyright-langserver --stdio` | `npm i -g pyright`（或 `pip install pyright`） |
| `typescript` | TS / TSX / JS / JSX | `typescript-language-server --stdio` | `npm i -g typescript-language-server typescript` |

> **前提条件：** 本插件只配置 Claude Code 如何连接语言服务器——**不包含**可执行文件。请自行安装
> 上述服务器。缺少可执行文件时，`/plugin` 的 Errors 标签页会显示 `Executable not found in $PATH`；
> 安装后请运行 `/reload-plugins`。
