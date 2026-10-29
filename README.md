# hhbp-claude-code

Heshuo Harness Best Practices — Claude Code plugin providing DDD-standard hooks, agents, and skills for Java Maven microservices development.

## Overview

`hhbp-claude-code` is a [Claude Code](https://claude.ai/code) plugin that enforces production-grade engineering practices across your development sessions. It brings together:

- **Automated code quality** — formats Java files on save and enforces git commit conventions
- **Domain-driven skills** — ready-made workflows for code generation, SQL analysis, API scaffolding, and security review aligned with DDD architecture

Repository: <https://github.com/rabbit4431/hhbp-claude-code>

## Features

- **2 safety hooks** — PreToolUse blocks dangerous shell commands; PostToolUse enforces git commit conventions
- **7 domain skills** — `/generate-code`, `/generate-api`, `/sql-analyze`, `/slow-sql-optimize`, `/remove-unused-class`, `/security-review`, `/docs-lookup`
- **6 specialized subagents** — planner, java-reviewer, java-build-resolver, security-reviewer, sql-performance-reviewer, docs-lookup
- **3 LSP servers** — jdtls (Java), Pyright (Python), and typescript-language-server (TS/JS) for go-to-definition, find-references, hover, and diagnostics
- **MCP configuration** — pre-configured MCP server settings in `common/mcp/`
- **Development standards** — DDD architecture spec and backend development standards in `spec/`

## Directory Structure

```
hhbp-claude-code/
├── agents/                     # Subagent definitions (planner, java-reviewer, security-reviewer, …)
└── common/                     # shared content (vendored via git subtree from hhbp-common)
    ├── hooks/
    │   └── hooks.json          # Claude Code hook registrations (PreToolUse / PostToolUse)
    ├── skills/                 # Skill definitions (generate-code, generate-api, sql-analyze, …)
    ├── scripts/
    │   └── hooks/              # Hook scripts (block-dangerous, git-workflow)
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

## Updating common

`common/` is vendored from [hhbp-common](https://github.com/rabbit4431/hhbp-common)
via git subtree. To pull the latest shared content:

```
# one-time: register the upstream remote
git remote add common https://github.com/rabbit4431/hhbp-common.git

# pull the latest common content into the common/ subtree
git subtree pull --prefix=common common main --squash
```

## Hooks Reference

| Event | Matcher | Script | Purpose |
|---|---|---|---|
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
