# hhbp-claude-code

[English](README.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Русский](README.ru.md) · **日本語** · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [한국어](README.ko.md)

Heshuo Harness Best Practices — Java Maven マイクロサービス開発向けに、DDD 標準に沿ったフック・エージェント・スキルを提供する Claude Code プラグインです。

## 概要

`hhbp-claude-code` は、開発セッション全体を通じて本番品質のエンジニアリングプラクティスを徹底させる [Claude Code](https://claude.ai/code) プラグインです。次の機能をまとめて提供します。

- **コード品質の自動化** — 保存時に Java ファイルを整形し、git のコミット規約を徹底します
- **ドメイン駆動のスキル** — DDD アーキテクチャに沿ったコード生成、SQL 分析、API のひな形作成、セキュリティレビューのためのすぐに使えるワークフロー

リポジトリ: <https://github.com/rabbit4431/hhbp-claude-code>

## 機能

- **3 つのフック** — SessionStart は選択した言語を適用し、PreToolUse は危険なシェルコマンドをブロックし、PostToolUse は git のコミット規約を徹底します
- **22 のスキル**
  - *マルチサービス機能ワークフロー* — `/springboot-feature-bootstrap` が 9 フェーズのチェーンを統括します: `/service-discovery`、`/feature-workspace-setup`、`/contract-first-design`、`/parallel-implementation`、`/multi-service-integration-test`、`/cross-service-review`、`/multi-branch-merge`、`/feature-cleanup`
  - *基盤* — `/test-driven-development`、`/writing-implementation-plan`、`/subagent-task-execution`、`/code-review-request`、`/finishing-a-feature-branch`、`/security-review`、`/docs-lookup`、`/language-setup`
  - *コード生成と SQL* — `/generate-api`、`/generate-code`、`/remove-unused-class`、`/sql-analyze`、`/slow-sql-optimize`
- **6 つの専門サブエージェント** — planner、java-reviewer、java-build-resolver、security-reviewer、sql-performance-reviewer、docs-lookup
- **3 つの LSP サーバー** — jdtls（Java）、Pyright（Python）、typescript-language-server（TS/JS）により、定義へのジャンプ、参照の検索、ホバー、診断を利用できます
- **MCP 設定** — `common/mcp/` に事前設定済みの MCP サーバー設定
- **開発標準** — `spec/` に DDD アーキテクチャ仕様とバックエンド開発標準
- **言語の選択** — 回答、計画、レポート、コミットメッセージの説明、コードコメントを 8 言語（英語、フランス語、ドイツ語、ロシア語、日本語、簡体字中国語、繁体字中国語、韓国語）で出力

## ディレクトリ構成

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

## インストール

```
/plugin marketplace add rabbit4431/hhbp-claude-code

/plugin install hhbp-claude-code@hhbp-claude-code
```

## 言語

プラグインを有効にすると、Claude Code が **言語**（*Language*）を尋ねます。

| コード | 言語 |
|---|---|
| `en` | English（デフォルト） |
| `fr` | Français |
| `de` | Deutsch |
| `ru` | Русский |
| `ja` | 日本語 |
| `zh-CN` | 简体中文 |
| `zh-TW` | 繁體中文 |
| `ko` | 한국어 |

以降、Claude はその言語で回答し、計画、レビュー、レポート、コミットメッセージの説明、コードコメントもその言語で書きます。コードの識別子、ファイル名、コマンド、コミットの `<type>:` プレフィックス、ワークフロープロトコルのトークン（`feature-state.json`、`REVIEW.md` の判定）は、スキルが正しく動作し続けるよう英語のままです。ブロックされたコマンドのメッセージも翻訳されます。

後から変更するには: `/plugin` → **Installed** → **hhbp-claude-code** → **Configure options**、または `/config`。新しい言語は次のセッションから適用されます。

> **Claude Code v2.1.271 以降が必要です** — 言語の選択には `userConfig` の `options` を使用しており、
> それより古いバージョンではプラグインを読み込めません。

スキル、エージェント、仕様書は英語で書かれています。言語設定が変えるのは出力だけです。

## common の更新

`common/` は [hhbp-common](https://github.com/rabbit4431/hhbp-common) から
git subtree で取り込まれています。最新の共有コンテンツを取得するには:

```
# one-time: register the upstream remote
git remote add common https://github.com/rabbit4431/hhbp-common.git

# pull the latest common content into the common/ subtree
git subtree pull --prefix=common common main --squash
```

## モデル

各スキルは `SKILL.md` の frontmatter（`model:`）で使用するモデルを固定しており、スキルが有効な間、Claude Code は自動的にそのモデルに切り替わります。`springboot-feature-bootstrap` ワークフローの各フェーズ移行時も同様です（`common/skills/springboot-feature-bootstrap/references/phase-dispatcher.md` の「Model selection」を参照）。

| ティア | モデル | スキル |
|---|---|---|
| design | `claude-opus-5-5` | service-discovery, contract-first-design, writing-implementation-plan, cross-service-review, code-review-request, security-review |
| impl | `claude-sonnet-5-5` | generate-api, generate-code, test-driven-development, parallel-implementation, subagent-task-execution, multi-service-integration-test, remove-unused-class, springboot-feature-bootstrap, feature-workspace-setup, multi-branch-merge, finishing-a-feature-branch, feature-cleanup, docs-lookup, language-setup |

`sql-analyze` と `slow-sql-optimize` はセッションのモデルを使います。スキルによるモデルの切り替えはそのターンの終わりまで有効で、組織の `availableModels` 許可リストに含まれないモデルの場合は無視されます（セッションのモデルのまま）。`agents/` のサブエージェントはそれぞれ独自の `model:` 設定を保持します。

`model:` frontmatter は Claude Code 専用です。Codex 版の兄弟プラグイン
[hhbp-codex](https://github.com/rabbit4431/hhbp-codex) はこれを無視し、すべてのスキルをセッションのモデルで実行します。

## フックリファレンス

| イベント | Matcher | スクリプト | 目的 |
|---|---|---|---|
| SessionStart | `startup\|resume\|clear\|compact` | `language.js` | 出力に使う言語を Claude に伝える |
| PreToolUse | `Bash` | `block-dangerous.js` | 危険なシェルコマンドを実行前にブロックする |
| PostToolUse | `Write\|Edit\|MultiEdit` | `git-workflow.js` | コミットのタイミングと形式のルールを徹底する |

## LSP リファレンス

言語サーバーは `LSP` ツールを通じて、Claude にリアルタイムのコードインテリジェンス（定義へのジャンプ、参照の検索、ホバー、診断）を提供します。`common/lsp/lsp.json` で設定し、プラグインマニフェストの `lspServers` フィールドで登録します。

| サーバー | 言語 | コマンド | インストール |
|---|---|---|---|
| `jdtls` | Java | `jdtls` | `brew install jdtls`（または [eclipse.jdt.ls](https://github.com/eclipse-jdtls/eclipse.jdt.ls)） |
| `pyright` | Python | `pyright-langserver --stdio` | `npm i -g pyright`（または `pip install pyright`） |
| `typescript` | TS / TSX / JS / JSX | `typescript-language-server --stdio` | `npm i -g typescript-language-server typescript` |

> **前提条件:** このプラグインは Claude Code が言語サーバーに接続する方法を設定するだけで、
> バイナリは**同梱していません**。上記のサーバーはご自身でインストールしてください。バイナリが
> 見つからない場合は、`/plugin` の Errors タブに `Executable not found in $PATH` と表示されます。
> インストール後に `/reload-plugins` を実行してください。
