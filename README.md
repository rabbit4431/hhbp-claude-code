# hhbp-claude-code

Heshuo Harness Best Practices — Claude Code plugin providing DDD-standard hooks, agents, skills, and session lifecycle automation for Java Maven microservices development.

## Overview

`hhbp-claude-code` is a [Claude Code](https://claude.ai/code) plugin that enforces production-grade engineering practices across your development sessions. It brings together:

- **Session continuity** — automatically loads prior context on every new session and persists session state on exit
- **Automated code quality** — formats Java files on save and enforces git commit conventions
- **Domain-driven skills** — ready-made workflows for code generation, SQL analysis, API scaffolding, and security review aligned with DDD architecture

Repository: <https://github.com/rabbit4431/hhbp-claude-code>

## Features

- **5 session lifecycle hooks** — SessionStart, PreToolUse, PostToolUse, SessionEnd, and Stop events wired to purpose-built scripts
- **7 domain skills** — `/generate-code`, `/generate-api`, `/sql-analyze`, `/slow-sql-optimize`, `/remove-unused-class`, `/security-review`, `/docs-lookup`
- **6 specialized subagents** — planner, java-reviewer, java-build-resolver, security-reviewer, sql-performance-reviewer, docs-lookup
- **`/sessions` slash command** — browse, alias, and restore past Claude Code sessions
- **3 LSP servers** — jdtls (Java), Pyright (Python), and typescript-language-server (TS/JS) for go-to-definition, find-references, hover, and diagnostics
- **MCP configuration** — pre-configured MCP server settings in `common/mcp/`
- **Development standards** — DDD architecture spec and backend development standards in `spec/`

## Directory Structure

```
hhbp-claude-code/
├── agents/                     # Subagent definitions (planner, java-reviewer, security-reviewer, …)
└── common/                     # shared content (git submodule → hhbp-common)
    ├── hooks/
    │   └── hooks.json          # Claude Code hook registrations (SessionStart / PreToolUse / PostToolUse / SessionEnd / Stop)
    ├── commands/
    │   └── sessions.md         # /sessions slash command definition
    ├── skills/                 # Skill definitions (generate-code, generate-api, sql-analyze, …)
    ├── scripts/
    │   ├── hooks/              # Session lifecycle JS scripts (session-start, session-end, block-dangerous, activity-tracker, …)
    │   └── lib/                # Shared utility library (package-manager, project-detect)
    ├── mcp/
    │   └── mcp.json            # MCP server configuration (context7)
    ├── lsp/
    │   └── lsp.json            # LSP server configuration (jdtls, pyright, typescript)
    ├── spec/                   # Architecture and coding standards docs
    └── tests/
        └── hooks/
            └── hooks.test.js   # Hook script test suite
```

## Installation

```
/plugin marketplace add rabbit4431/hhbp-claude-code

/plugin install hhbp-claude-code@hhbp-claude-code
```

## Hooks Reference

| Event | Matcher | Script | Purpose |
|---|---|---|---|
| SessionStart | `*` | `session-start-bootstrap.js` | Load previous context and detect package manager |
| PreToolUse | `Bash` | `block-dangerous.js` | Block dangerous shell commands before execution |
| PostToolUse | `Write\|Edit\|MultiEdit` | `git-workflow.js` | Enforce commit timing and format rules |
| PostToolUse | `*` | `session-activity-tracker.js` | Record per-tool activity metrics (async) |
| SessionEnd | `*` | `session-end-marker.js` | Write session end marker (non-blocking, async) |
| Stop | `*` | `session-end.js` | Persist session state after each response |

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
