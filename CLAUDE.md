# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the **Claude Code plugin** for Heshuo Harness Best Practices (HHBP) — providing production-ready hooks, commands, and session lifecycle automation for Claude Code.

Shared content (agents, skills, spec, MCP configs, hook scripts) lives in the `common/` git submodule (`hhbp-common`).

## Architecture

- **common/agents/** - Specialized subagents for delegation (planner, java-reviewer, etc.)
- **common/skills/** - Workflow definitions and domain knowledge (code generation, security review, etc.)
- **common/hooks/** - Hook scripts (block-dangerous, format-java, run-hook.cmd)
- **common/scripts/hooks/** - Session lifecycle scripts (session-start, session-end, git-workflow)
- **common/mcp-configs/** - MCP server configurations
- **hooks/hooks.json** - Claude Code hook registration (SessionStart/PreToolUse/PostToolUse/SessionEnd/Stop)
- **commands/** - Slash commands invoked by users (/sessions, etc.)
- **tests/** - Test suite for hook scripts
