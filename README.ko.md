# hhbp-claude-code

[English](README.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Русский](README.ru.md) · [日本語](README.ja.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · **한국어**

Heshuo Harness Best Practices — Java Maven 마이크로서비스 개발을 위해 DDD 표준에 맞춘 훅, 에이전트, 스킬을 제공하는 Claude Code 플러그인입니다.

## 개요

`hhbp-claude-code`는 개발 세션 전반에 걸쳐 프로덕션 수준의 엔지니어링 관행을 적용하는 [Claude Code](https://claude.ai/code) 플러그인입니다. 다음을 함께 제공합니다.

- **자동화된 코드 품질** — 저장 시 Java 파일을 포맷하고 git 커밋 규칙을 적용합니다
- **도메인 주도 스킬** — DDD 아키텍처에 맞춘 코드 생성, SQL 분석, API 스캐폴딩, 보안 검토용 즉시 사용 가능한 워크플로

저장소: <https://github.com/rabbit4431/hhbp-claude-code>

## 기능

- **훅 3개** — SessionStart는 선택한 언어를 적용하고, PreToolUse는 위험한 셸 명령을 차단하며, PostToolUse는 git 커밋 규칙을 적용합니다
- **스킬 22개**
  - *멀티 서비스 기능 워크플로* — `/springboot-feature-bootstrap`이 9단계 체인을 조율합니다: `/service-discovery`, `/feature-workspace-setup`, `/contract-first-design`, `/parallel-implementation`, `/multi-service-integration-test`, `/cross-service-review`, `/multi-branch-merge`, `/feature-cleanup`
  - *기반* — `/test-driven-development`, `/writing-implementation-plan`, `/subagent-task-execution`, `/code-review-request`, `/finishing-a-feature-branch`, `/security-review`, `/docs-lookup`, `/language-setup`
  - *코드 생성 및 SQL* — `/generate-api`, `/generate-code`, `/remove-unused-class`, `/sql-analyze`, `/slow-sql-optimize`
- **전문 서브에이전트 6개** — planner, java-reviewer, java-build-resolver, security-reviewer, sql-performance-reviewer, docs-lookup
- **LSP 서버 3개** — jdtls(Java), Pyright(Python), typescript-language-server(TS/JS)로 정의로 이동, 참조 찾기, 호버, 진단을 지원합니다
- **MCP 구성** — `common/mcp/`에 미리 구성된 MCP 서버 설정
- **개발 표준** — `spec/`에 DDD 아키텍처 명세와 백엔드 개발 표준
- **언어 선택** — 답변, 계획, 보고서, 커밋 메시지 설명, 코드 주석을 8개 언어(영어, 프랑스어, 독일어, 러시아어, 일본어, 중국어 간체, 중국어 번체, 한국어)로 작성

## 디렉터리 구조

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

## 설치

```
/plugin marketplace add rabbit4431/hhbp-claude-code

/plugin install hhbp-claude-code@hhbp-claude-code
```

## 언어

플러그인을 활성화하면 Claude Code가 **언어**(*Language*)를 묻습니다.

| 코드 | 언어 |
|---|---|
| `en` | English (기본값) |
| `fr` | Français |
| `de` | Deutsch |
| `ru` | Русский |
| `ja` | 日本語 |
| `zh-CN` | 简体中文 |
| `zh-TW` | 繁體中文 |
| `ko` | 한국어 |

이후 Claude는 해당 언어로 답변하고, 계획, 리뷰, 보고서, 커밋 메시지 설명, 코드 주석도 그 언어로 작성합니다. 코드 식별자, 파일 이름, 명령, 커밋 `<type>:` 접두사, 워크플로 프로토콜 토큰(`feature-state.json`, `REVIEW.md` 판정)은 스킬이 계속 작동하도록 영어로 유지됩니다. 차단된 명령의 메시지도 번역됩니다.

나중에 변경하려면: `/plugin` → **Installed** → **hhbp-claude-code** → **Configure options** 또는 `/config`. 새 언어는 다음 세션부터 적용됩니다.

> **Claude Code v2.1.271 이상이 필요합니다** — 언어 선택은 `userConfig`의 `options`를 사용하며,
> 이전 버전에서는 플러그인을 불러올 수 없습니다.

스킬, 에이전트, 명세는 영어로 작성되어 있으며, 언어 설정은 출력에만 영향을 줍니다.

## common 업데이트

`common/`은 [hhbp-common](https://github.com/rabbit4431/hhbp-common)에서
git subtree로 가져옵니다. 최신 공유 콘텐츠를 받으려면:

```
# one-time: register the upstream remote
git remote add common https://github.com/rabbit4431/hhbp-common.git

# pull the latest common content into the common/ subtree
git subtree pull --prefix=common common main --squash
```

## 모델

각 스킬은 `SKILL.md` frontmatter(`model:`)에 사용할 모델을 고정하며, 스킬이 활성화된 동안 Claude Code가 자동으로 해당 모델로 전환합니다. `springboot-feature-bootstrap` 워크플로의 모든 단계 전환에서도 마찬가지입니다(`common/skills/springboot-feature-bootstrap/references/phase-dispatcher.md`의 "Model selection" 참고).

| 티어 | 모델 | 스킬 |
|---|---|---|
| design | `claude-opus-5-5` | service-discovery, contract-first-design, writing-implementation-plan, cross-service-review, code-review-request, security-review |
| impl | `claude-sonnet-5-5` | generate-api, generate-code, test-driven-development, parallel-implementation, subagent-task-execution, multi-service-integration-test, remove-unused-class, springboot-feature-bootstrap, feature-workspace-setup, multi-branch-merge, finishing-a-feature-branch, feature-cleanup, docs-lookup, language-setup |

`sql-analyze`와 `slow-sql-optimize`는 세션 모델을 사용합니다. 스킬의 모델 전환은 해당 턴이 끝날 때까지 유지되며, 조직의 `availableModels` 허용 목록에 없는 모델이면 무시됩니다(세션 모델 유지). `agents/`의 서브에이전트는 각자의 `model:` 설정을 유지합니다.

`model:` frontmatter는 Claude Code 전용입니다. Codex용 자매 플러그인
[hhbp-codex](https://github.com/rabbit4431/hhbp-codex)는 이를 무시하고 모든 스킬을 세션 모델로 실행합니다.

## 훅 참고

| 이벤트 | Matcher | 스크립트 | 목적 |
|---|---|---|---|
| SessionStart | `startup\|resume\|clear\|compact` | `language.js` | 출력에 사용할 언어를 Claude에 알림 |
| PreToolUse | `Bash` | `block-dangerous.js` | 위험한 셸 명령을 실행 전에 차단 |
| PostToolUse | `Write\|Edit\|MultiEdit` | `git-workflow.js` | 커밋 시점과 형식 규칙 적용 |

## LSP 참고

언어 서버는 `LSP` 도구를 통해 Claude에 실시간 코드 인텔리전스(정의로 이동, 참조 찾기, 호버, 진단)를 제공합니다. `common/lsp/lsp.json`에서 구성하며 플러그인 매니페스트의 `lspServers` 필드로 등록합니다.

| 서버 | 언어 | 명령 | 설치 |
|---|---|---|---|
| `jdtls` | Java | `jdtls` | `brew install jdtls` (또는 [eclipse.jdt.ls](https://github.com/eclipse-jdtls/eclipse.jdt.ls)) |
| `pyright` | Python | `pyright-langserver --stdio` | `npm i -g pyright` (또는 `pip install pyright`) |
| `typescript` | TS / TSX / JS / JSX | `typescript-language-server --stdio` | `npm i -g typescript-language-server typescript` |

> **사전 요구 사항:** 이 플러그인은 Claude Code가 언어 서버에 연결하는 방법만 구성하며 바이너리는
> **포함하지 않습니다**. 위 서버들은 직접 설치하세요. 바이너리가 없으면 `/plugin`의 Errors 탭에
> `Executable not found in $PATH`로 표시됩니다. 설치 후 `/reload-plugins`를 실행하세요.
