# hhbp-claude-code

[English](README.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Русский](README.ru.md) · [日本語](README.ja.md) · [简体中文](README.zh-CN.md) · **繁體中文** · [한국어](README.ko.md)

Heshuo Harness Best Practices —— 為 Java Maven 微服務開發打造的 Claude Code 外掛，提供符合 DDD 規範的掛鉤（hooks）、代理（agents）與技能（skills）。

## 概覽

`hhbp-claude-code` 是一個 [Claude Code](https://claude.ai/code) 外掛，在整個開發工作階段中落實正式環境等級的工程實務。它包含：

- **自動化程式碼品質** —— 儲存時格式化 Java 檔案，並強制執行 git 提交規範
- **領域驅動的技能** —— 開箱即用的工作流程，涵蓋程式碼產生、SQL 分析、API 骨架建立與安全性審查，皆與 DDD 架構一致

儲存庫：<https://github.com/rabbit4431/hhbp-claude-code>

## 功能

- **3 個掛鉤** —— SessionStart 套用你選擇的語言；PreToolUse 封鎖危險的 shell 指令；PostToolUse 強制執行 git 提交規範
- **22 個技能**
  - *多服務功能工作流程* —— `/springboot-feature-bootstrap` 協調 9 個階段的流程鏈：`/service-discovery`、`/feature-workspace-setup`、`/contract-first-design`、`/parallel-implementation`、`/multi-service-integration-test`、`/cross-service-review`、`/multi-branch-merge`、`/feature-cleanup`
  - *基礎* —— `/test-driven-development`、`/writing-implementation-plan`、`/subagent-task-execution`、`/code-review-request`、`/finishing-a-feature-branch`、`/security-review`、`/docs-lookup`、`/language-setup`
  - *程式碼產生與 SQL* —— `/generate-api`、`/generate-code`、`/remove-unused-class`、`/sql-analyze`、`/slow-sql-optimize`
- **6 個專用子代理** —— planner、java-reviewer、java-build-resolver、security-reviewer、sql-performance-reviewer、docs-lookup
- **3 個 LSP 伺服器** —— jdtls（Java）、Pyright（Python）與 typescript-language-server（TS/JS），支援跳至定義、尋找參考、懸停提示與診斷
- **MCP 設定** —— `common/mcp/` 中預先設定好的 MCP 伺服器設定
- **開發規範** —— `spec/` 中的 DDD 架構規範與後端開發規範
- **語言選擇** —— 回覆、計畫、報告、提交訊息描述與程式碼註解支援 8 種語言：英文、法文、德文、俄文、日文、簡體中文、繁體中文與韓文

## 目錄結構

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

## 安裝

```
/plugin marketplace add rabbit4431/hhbp-claude-code

/plugin install hhbp-claude-code@hhbp-claude-code
```

## 語言

啟用外掛時，Claude Code 會請你選擇 **語言**（*Language*）：

| 代碼 | 語言 |
|---|---|
| `en` | English（預設） |
| `fr` | Français |
| `de` | Deutsch |
| `ru` | Русский |
| `ja` | 日本語 |
| `zh-CN` | 简体中文 |
| `zh-TW` | 繁體中文 |
| `ko` | 한국어 |

之後 Claude 會以該語言回覆，並以該語言撰寫計畫、審查、報告、提交訊息描述與程式碼註解。程式碼識別字、檔案名稱、指令、提交前綴 `<type>:` 以及工作流程協定中的標記（`feature-state.json`、`REVIEW.md` 的結論）維持英文，以確保各技能正常運作。被封鎖指令的提示訊息也會翻譯。

之後若要變更：`/plugin` → **Installed** → **hhbp-claude-code** → **Configure options**，或使用 `/config`。新語言從下一個工作階段開始生效。

> **需要 Claude Code v2.1.271 或更新版本** —— 語言選擇使用了 `userConfig` 的 `options`，
> 較舊的版本無法載入此外掛。

技能、代理與規範文件皆以英文撰寫；語言設定只影響輸出。

## 更新 common

`common/` 透過 git subtree 從 [hhbp-common](https://github.com/rabbit4431/hhbp-common)
引入。取得最新的共用內容：

```
# one-time: register the upstream remote
git remote add common https://github.com/rabbit4431/hhbp-common.git

# pull the latest common content into the common/ subtree
git subtree pull --prefix=common common main --squash
```

## 模型

每個技能在 `SKILL.md` 的 frontmatter（`model:`）中固定所用模型，技能啟用期間 Claude Code 會自動切換到該模型——包括 `springboot-feature-bootstrap` 工作流程的每次階段轉換（請參閱 `common/skills/springboot-feature-bootstrap/references/phase-dispatcher.md` 中的「Model selection」）。

| 層級 | 模型 | 技能 |
|---|---|---|
| design | `claude-opus-5-5` | service-discovery, contract-first-design, writing-implementation-plan, cross-service-review, code-review-request, security-review |
| impl | `claude-sonnet-5-5` | generate-api, generate-code, test-driven-development, parallel-implementation, subagent-task-execution, multi-service-integration-test, remove-unused-class, springboot-feature-bootstrap, feature-workspace-setup, multi-branch-merge, finishing-a-feature-branch, feature-cleanup, docs-lookup, language-setup |

`sql-analyze` 與 `slow-sql-optimize` 沿用工作階段的模型。技能的模型切換在本輪結束前有效；若組織的 `availableModels` 允許清單不包含該模型，則會被忽略（維持工作階段的模型）。`agents/` 中的子代理保留各自的 `model:` 設定。

`model:` frontmatter 僅適用於 Claude Code：Codex 版的姊妹外掛
[hhbp-codex](https://github.com/rabbit4431/hhbp-codex) 會忽略它，所有技能都以工作階段的模型執行。

## 掛鉤參考

| 事件 | Matcher | 指令碼 | 用途 |
|---|---|---|---|
| SessionStart | `startup\|resume\|clear\|compact` | `language.js` | 告訴 Claude 輸出要使用哪種語言 |
| PreToolUse | `Bash` | `block-dangerous.js` | 在執行前封鎖危險的 shell 指令 |
| PostToolUse | `Write\|Edit\|MultiEdit` | `git-workflow.js` | 強制執行提交時機與格式規則 |

## LSP 參考

語言伺服器透過 `LSP` 工具為 Claude 提供即時的程式碼智慧功能（跳至定義、尋找參考、懸停提示、診斷）。它們在 `common/lsp/lsp.json` 中設定，並透過外掛資訊清單的 `lspServers` 欄位註冊。

| 伺服器 | 語言 | 指令 | 安裝 |
|---|---|---|---|
| `jdtls` | Java | `jdtls` | `brew install jdtls`（或 [eclipse.jdt.ls](https://github.com/eclipse-jdtls/eclipse.jdt.ls)） |
| `pyright` | Python | `pyright-langserver --stdio` | `npm i -g pyright`（或 `pip install pyright`） |
| `typescript` | TS / TSX / JS / JSX | `typescript-language-server --stdio` | `npm i -g typescript-language-server typescript` |

> **前置需求：** 此外掛只設定 Claude Code 如何連線到語言伺服器——**不包含**執行檔。請自行安裝
> 上述伺服器。缺少執行檔時，`/plugin` 的 Errors 分頁會顯示 `Executable not found in $PATH`；
> 安裝後請執行 `/reload-plugins`。
