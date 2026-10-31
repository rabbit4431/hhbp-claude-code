# hhbp-claude-code

[English](README.md) · **Français** · [Deutsch](README.de.md) · [Русский](README.ru.md) · [日本語](README.ja.md) · [简体中文](README.zh-CN.md) · [繁體中文](README.zh-TW.md) · [한국어](README.ko.md)

Heshuo Harness Best Practices — plugin Claude Code fournissant des hooks, des agents et des skills conformes au DDD pour le développement de microservices Java Maven.

## Présentation

`hhbp-claude-code` est un plugin [Claude Code](https://claude.ai/code) qui applique des pratiques d'ingénierie de niveau production tout au long de vos sessions de développement. Il réunit :

- **Qualité de code automatisée** — formate les fichiers Java à l'enregistrement et applique les conventions de commit git
- **Skills orientés domaine** — des workflows prêts à l'emploi pour la génération de code, l'analyse SQL, la génération d'API et la revue de sécurité, alignés sur l'architecture DDD

Dépôt : <https://github.com/rabbit4431/hhbp-claude-code>

## Fonctionnalités

- **3 hooks** — SessionStart applique la langue choisie ; PreToolUse bloque les commandes shell dangereuses ; PostToolUse applique les conventions de commit git
- **22 skills**
  - *Workflow de fonctionnalité multi-services* — `/springboot-feature-bootstrap` orchestre la chaîne en 9 phases : `/service-discovery`, `/feature-workspace-setup`, `/contract-first-design`, `/parallel-implementation`, `/multi-service-integration-test`, `/cross-service-review`, `/multi-branch-merge`, `/feature-cleanup`
  - *Fondations* — `/test-driven-development`, `/writing-implementation-plan`, `/subagent-task-execution`, `/code-review-request`, `/finishing-a-feature-branch`, `/security-review`, `/docs-lookup`, `/language-setup`
  - *Génération de code & SQL* — `/generate-api`, `/generate-code`, `/remove-unused-class`, `/sql-analyze`, `/slow-sql-optimize`
- **6 sous-agents spécialisés** — planner, java-reviewer, java-build-resolver, security-reviewer, sql-performance-reviewer, docs-lookup
- **3 serveurs LSP** — jdtls (Java), Pyright (Python) et typescript-language-server (TS/JS) pour l'accès à la définition, la recherche de références, le survol et les diagnostics
- **Configuration MCP** — paramètres de serveur MCP préconfigurés dans `common/mcp/`
- **Standards de développement** — spécification d'architecture DDD et standards de développement backend dans `spec/`
- **Choix de la langue** — réponses, plans, rapports, descriptions de commit et commentaires de code en 8 langues : anglais, français, allemand, russe, japonais, chinois simplifié, chinois traditionnel et coréen

## Structure des répertoires

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

## Langue

Lorsque vous activez le plugin, Claude Code vous demande une **langue** (*Language*) :

| Code | Langue |
|---|---|
| `en` | English (par défaut) |
| `fr` | Français |
| `de` | Deutsch |
| `ru` | Русский |
| `ja` | 日本語 |
| `zh-CN` | 简体中文 |
| `zh-TW` | 繁體中文 |
| `ko` | 한국어 |

Claude répond alors dans cette langue et l'utilise pour rédiger les plans, revues, rapports, descriptions de commit et commentaires de code. Les identifiants de code, noms de fichiers, commandes, le préfixe de commit `<type>:` et les jetons du protocole de workflow (`feature-state.json`, verdicts de `REVIEW.md`) restent en anglais pour que les skills continuent de fonctionner. Les messages des commandes bloquées sont également traduits.

Pour la modifier plus tard : `/plugin` → **Installed** → **hhbp-claude-code** → **Configure options**, ou `/config`. La nouvelle langue s'applique à partir de la session suivante.

> **Nécessite Claude Code v2.1.271 ou une version ultérieure** — le sélecteur de langue utilise les
> `options` de `userConfig`, que les versions antérieures ne peuvent pas charger.

Les skills, agents et spécifications sont rédigés en anglais ; le réglage de langue ne concerne que les sorties.

## Mise à jour de common

`common/` est intégré depuis [hhbp-common](https://github.com/rabbit4431/hhbp-common)
via git subtree. Pour récupérer le dernier contenu partagé :

```
# one-time: register the upstream remote
git remote add common https://github.com/rabbit4431/hhbp-common.git

# pull the latest common content into the common/ subtree
git subtree pull --prefix=common common main --squash
```

## Modèles

Chaque skill fixe son modèle dans le frontmatter de `SKILL.md` (`model:`), et Claude Code bascule automatiquement sur ce modèle tant que le skill est actif — y compris à chaque transition de phase du workflow `springboot-feature-bootstrap` (voir « Model selection » dans `common/skills/springboot-feature-bootstrap/references/phase-dispatcher.md`).

| Niveau | Modèle | Skills |
|---|---|---|
| design | `claude-opus-5-5` | service-discovery, contract-first-design, writing-implementation-plan, cross-service-review, code-review-request, security-review |
| impl | `claude-sonnet-5-5` | generate-api, generate-code, test-driven-development, parallel-implementation, subagent-task-execution, multi-service-integration-test, remove-unused-class, springboot-feature-bootstrap, feature-workspace-setup, multi-branch-merge, finishing-a-feature-branch, feature-cleanup, docs-lookup, language-setup |

`sql-analyze` et `slow-sql-optimize` conservent le modèle de la session. Le changement de modèle d'un skill dure jusqu'à la fin du tour, et il est ignoré (le modèle de la session est conservé) si la liste `availableModels` de votre organisation l'exclut. Les sous-agents de `agents/` conservent leur propre réglage `model:`.

Le frontmatter `model:` est propre à Claude Code : le plugin jumeau pour Codex,
[hhbp-codex](https://github.com/rabbit4431/hhbp-codex), l'ignore et exécute chaque skill avec le modèle de la session.

## Référence des hooks

| Événement | Matcher | Script | Rôle |
|---|---|---|---|
| SessionStart | `startup\|resume\|clear\|compact` | `language.js` | Indiquer à Claude la langue à utiliser pour les sorties |
| PreToolUse | `Bash` | `block-dangerous.js` | Bloquer les commandes shell dangereuses avant leur exécution |
| PostToolUse | `Write\|Edit\|MultiEdit` | `git-workflow.js` | Appliquer les règles de moment et de format des commits |

## Référence LSP

Les serveurs de langage donnent à Claude une intelligence de code en temps réel (accès à la définition, recherche de références, survol, diagnostics) via l'outil `LSP`. Ils sont configurés dans `common/lsp/lsp.json` et enregistrés via le champ `lspServers` du manifeste du plugin.

| Serveur | Langage(s) | Commande | Installation |
|---|---|---|---|
| `jdtls` | Java | `jdtls` | `brew install jdtls` (ou [eclipse.jdt.ls](https://github.com/eclipse-jdtls/eclipse.jdt.ls)) |
| `pyright` | Python | `pyright-langserver --stdio` | `npm i -g pyright` (ou `pip install pyright`) |
| `typescript` | TS / TSX / JS / JSX | `typescript-language-server --stdio` | `npm i -g typescript-language-server typescript` |

> **Prérequis :** le plugin configure uniquement la façon dont Claude Code se connecte à un serveur
> de langage — il **n'inclut pas** les binaires. Installez vous-même les serveurs ci-dessus. Un
> binaire manquant apparaît comme `Executable not found in $PATH` dans l'onglet Errors de `/plugin` ;
> exécutez `/reload-plugins` après l'installation.
