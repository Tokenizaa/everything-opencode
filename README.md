# 🚀 opencode-agents

**33 agents + 69 skills prontos para o OpenCode** — uma arquitetura completa de agentes de IA para desenvolvimento de software, com discovery pipeline, simbiose com superpowers, design systems e suporte a IA via 9Router (FREE).

> Alternativa open-source e local-first para times que querem agentes especializados, organizados por camada e domínio, sem depender de plataformas fechadas.

---

## 📖 Índice

- [Visão Geral](#-visão-geral)
- [Características](#-características)
- [Requisitos](#-requisitos)
- [Instalação](#-instalação)
- [Uso Rápido](#-uso-rápido)
- [Arquitetura de Agentes](#-arquitetura-de-agentes)
- [Skills](#-skills)
- [Configuração Avançada](#-configuração-avançada)
- [Exemplos Práticos](#-exemplos-práticos)
- [Troubleshooting](#-troubleshooting)
- [Fontes Integradas](#-fontes-integradas)
- [Licença](#-licença)

---

## 🎯 Visão Geral

O `opencode-agents` transforma o OpenCode em um **time de agentes especializados** que trabalham juntos:

| Camada | Agentes | Função |
|--------|---------|--------|
| **Governança** | supervisor, qualidade, documentacao, descoberta | Orquestram, revisam, documentam |
| **Backend** | backend + 5 subagentes | Rotas, serviços, auth, middleware, validação |
| **Banco de Dados** | banco + 4 subagentes | Schema, queries, migrations, índices |
| **Frontend** | frontend + 4 subagentes | Components, estado, roteamento, estilos |
| **Testes** | testes + 4 subagentes | Unit, integração, E2E, performance |
| **Especializados** | seguranca, build-error-resolver, refactor-cleaner | Segurança, build, limpeza |
| **Orquestradores** | marketing, cloudflare, 9router, design | Domínios amplos com muitas skills |
| **IA** | ia | Chat, imagem, TTS, STT, embeddings, web (FREE) |

### Filosofia

- **Discovery First** — agentes de domínio são gerados a partir da análise real do projeto (pipeline de 10 fases)
- **Zero assumptions** — não assumimos framework, linguagem ou stack
- **Handoff silencioso** — agentes se chamam automaticamente via `task tool`
- **Disciplina de processo** — TDD, systematic-debugging e verificação obrigatórias (superpowers + Karpathy)
- **IA FREE** — tudo via 9Router com providers NVIDIA + combo (sem custo)

---

## 🔧 Requisitos

| Requisito | Necessário | Detalhe |
|---|---|---|
| [OpenCode](https://opencode.ai) | ✅ Obrigatório | `curl -fsSL https://opencode.ai/install \| bash` |
| [9Router](https://github.com/decolua/9router) | ⚠️ Recomendado | Gateway de IA local em `http://localhost:20128` |
| Node.js 18+ | ✅ Obrigatório | Para o OpenCode |
| [Superpowers](https://github.com/obra/superpowers) | ⚠️ Recomendado | Plugin de processo (instalado pelo instalador) |

---

## ⚡ Instalação

### Método 1 — Instalador (recomendado)

```bash
# 1. Clone
git clone https://github.com/Tokenizaa/opencode-agents.git
cd opencode-agents

# 2. Instale agents + skills + AGENTS.md
bash install.sh

# 3. (Opcional) Biblioteca de design — 153 marcas + 115 templates (~81MB)
bash install.sh --design

# 4. Reinicie o OpenCode
```

### Método 2 — Instalação direta via curl

```bash
curl -fsSL https://raw.githubusercontent.com/Tokenizaa/opencode-agents/main/install.sh | bash
```

### Método 3 — Manual

```bash
# Copiar agents
mkdir -p ~/.config/opencode/agents
cp agents/*.md ~/.config/opencode/agents/

# Copiar skills
mkdir -p ~/.config/opencode/skills
cp -r skills/* ~/.config/opencode/skills/

# Topologia
cp AGENTS.md ~/.opencode/AGENTS.md
```

### O que o instalador faz

| Ação | Destino | Comportamento |
|---|---|---|
| 33 agents | `~/.config/opencode/agents/` | Não sobrescreve existentes |
| 69 skills | `~/.config/opencode/skills/` | Não sobrescreve existentes |
| opencode.jsonc | `~/.config/opencode/` | **Preserva** config existente (faz backup) |
| AGENTS.md | `~/.opencode/AGENTS.md` | Preserva se existir |
| Design (--design) | `~/.config/opencode/design/` | Download opcional |

> 🔒 **Seguro**: o instalador NUNCA destrói sua configuração — faz backup automático antes de qualquer alteração.

---

## 🚀 Uso Rápido

### Alternar entre agents (Tab)

Pressione **Tab** para ciclar entre os agents primários:

```
build → plan → supervisor → qualidade → documentacao → descoberta →
backend → banco → frontend → testes → seguranca → marketing →
cloudflare → 9router → design
```

### Invocar agentes específicos (@)

Digite `@` + nome do agente para invocá-lo diretamente:

```
@backend "criar rota de login"
@banco "otimizar query de relatório"
@frontend "criar página de perfil"
@testes "escrever testes E2E do checkout"
@seguranca "auditar autenticação"
```

### Comando universal: "qual sua função"

**Qualquer agent** responde a:

```
@banco "qual sua função"
@supervisor "o que você faz"
@design "me apresente"
```

O agente carrega sua skill e apresenta: **Função → Escopo → Skills que carrega → Subagentes → Quando recomendar outros**.

---

## 🧩 Arquitetura de Agentes

### Agentes de Governança (Tab + @)

| Agente | Modo | Papel |
|--------|------|-------|
| `@supervisor` | all | Orquestrador — distribui tarefas, resolve conflitos, aciona descoberta |
| `@qualidade` | all | Guardião de qualidade — revisa PRs, valida SOLID, pode vetar |
| `@documentacao` | all | Documentação viva — ADRs, topologia, roadmap |
| `@descoberta` | all | Discovery pipeline — analisa projeto, gera agentes de domínio |

### Backend (skill: backend-dev-guidelines, api-patterns, nestjs-expert, fastapi-pro, cloudflare, wrangler)

| Agente | Modo | Responsabilidade |
|--------|------|-----------------|
| `@backend` | all | Coordenação geral |
| `@backend-routes` | subagent | Rotas, controllers, handlers |
| `@backend-services` | subagent | Lógica de negócio, use cases |
| `@backend-auth` | subagent | Autenticação, JWT, OAuth, RBAC |
| `@backend-middleware` | subagent | Middleware, interceptors, CORS |
| `@backend-validation` | subagent | DTOs, schemas, validação |

### Banco de Dados (skill: database-design, postgres-best-practices)

| Agente | Modo | Responsabilidade |
|--------|------|-----------------|
| `@banco` | all | Coordenação geral |
| `@banco-schema` | subagent | Schema, entidades, relacionamentos |
| `@banco-queries` | subagent | CRUD, joins, agregações |
| `@banco-migrations` | subagent | Migrations, versionamento |
| `@banco-indexing` | subagent | Índices, EXPLAIN, performance |

### Frontend (skill: frontend-dev-guidelines, react-patterns, react-best-practices, impeccable, web-perf)

| Agente | Modo | Responsabilidade |
|--------|------|-----------------|
| `@frontend` | all | Coordenação geral |
| `@frontend-components` | subagent | UI components, composição |
| `@frontend-state` | subagent | Estado local/global/server |
| `@frontend-routing` | subagent | Rotas client-side, layouts |
| `@frontend-styling` | subagent | Estilos, theming, tokens |

### Testes (skill: e2e-testing-patterns, python-testing-patterns, playwright-cli, web-perf)

| Agente | Modo | Responsabilidade |
|--------|------|-----------------|
| `@testes` | all | Estratégia e coordenação |
| `@testes-unit` | subagent | Testes unitários, mocks |
| `@testes-integracao` | subagent | Testes de integração |
| `@testes-e2e` | subagent | E2E, Playwright/Cypress |
| `@testes-performance` | subagent | Carga e performance |

### Especializados

| Agente | Modo | Responsabilidade |
|--------|------|-----------------|
| `@seguranca` | all | OWASP, secrets, SSRF, injection |
| `@build-error-resolver` | subagent | Corrige build/type com diff mínimo |
| `@refactor-cleaner` | subagent | Dead code, duplicatas |

### Orquestradores (muitas skills)

| Agente | Modo | Skills que coordena |
|--------|------|---------------------|
| `@marketing` | all | 47 skills (SEO, ads, email, content...) |
| `@cloudflare` | all | 10 skills (Workers, KV, D1, R2, Zero Trust...) |
| `@9router` | all | 8 skills (chat, imagem, TTS, STT, embeddings, web) |
| `@design` | all | 9 skills + biblioteca (153 design-systems) |

### IA FREE

| Agente | Modo | Responsabilidade |
|--------|------|-----------------|
| `@ia` | subagent | Chat, imagem, TTS, STT, embeddings, web via 9Router |

---

## 📚 Skills

### Agent-skills (18) — carregadas pelos agents

`agent-supervisor` · `agent-architecture-review` · `agent-context` · `agent-discovery-pipeline` · `agent-backend` · `agent-database` · `agent-frontend` · `agent-testing` · `agent-security-review` · `agent-build-fix` · `agent-refactor` · `agent-marketing` · `agent-cloudflare` · `agent-9router` · `agent-design` · `agent-ia` · `agent-generator` · `agent-all`

### Operacionais (51) — padrões e diretrizes

| Categoria | Skills |
|-----------|--------|
| **Backend** | backend-dev-guidelines, backend-patterns, api-patterns, api-design-principles, nestjs-expert, fastapi-pro, python-patterns |
| **Database** | database-design, postgres-best-practices |
| **Frontend** | frontend-dev-guidelines, frontend-patterns, react-patterns, react-best-practices, frontend-design, web-design-guidelines, shadcn, impeccable, web-perf |
| **Testes** | e2e-testing-patterns, python-testing-patterns, tdd-workflow, verification-loop, webapp-testing, playwright-cli |
| **Segurança** | security-review, code-review-checklist, code-reviewer |
| **Processo** | brainstorming, writing-plans, executing-plans, subagent-driven-development, dispatching-parallel-agents, systematic-debugging, test-driven-development, verification-before-completion, requesting-code-review, receiving-code-review, finishing-a-development-branch, using-git-worktrees, karpathy-guidelines |
| **Cloudflare** | cloudflare, wrangler, workers-best-practices, cloudflare-email-service, cloudflare-one, durable-objects, agents-sdk, turnstile-spin |
| **Docs** | pdf, pptx, docx, xlsx, mcp-builder, concise-planning, context-fundamentals, strategic-compact, continuous-learning, eval-harness |
| **Pagamentos** | stripe |

### Disciplina de código (Karpathy — todos os agents)

1. **Think Before Coding** — explicite assumptions, não assuma
2. **Simplicity First** — mínimo código, nada especulativo
3. **Surgical Changes** — toque só o necessário
4. **Goal-Driven** — critérios de sucesso verificáveis

---

## ⚙️ Configuração Avançada

### 1. 9Router (IA FREE)

```bash
# Variáveis de ambiente
export NINEROUTER_URL="http://localhost:20128"
export NINEROUTER_KEY="sk-..."   # apenas se auth habilitada

# Verificar
curl $NINEROUTER_URL/api/health   # → {"ok":true}
```

Providers FREE: **NVIDIA** (FastPitch, Tacotron2, NV-Embed-v2, Parakeet) + **9router combo** (Edge TTS, Google TTS, Gemini, Tavily, Brave, Jina...).

### 2. Plugin Superpowers

Adicione ao `~/.config/opencode/opencode.jsonc`:

```json
{
  "plugin": ["superpowers@git+https://github.com/obra/superpowers.git"]
}
```

Garante os HARD-GATEs de processo: **nada de código sem teste falhando, nada de fix sem root cause, nada de "pronto" sem evidência**.

### 3. MCPs (exemplo)

```json
{
  "mcp": {
    "context7": { "type": "local", "command": ["npx", "-y", "@upstash/context7-mcp@1.0.31"] },
    "playwright": { "type": "local", "command": ["npx", "-y", "@playwright/mcp@latest"] }
  }
}
```

### 4. Biblioteca de Design (opcional)

```bash
bash install.sh --design
# → ~/.config/opencode/design/
#   ├── design-systems/   (153 marcas: Apple, Airbnb, Linear...)
#   ├── design-templates/ (115 templates)
#   └── prompt-templates/ (106 prompts)
```

---

## 🎬 Exemplos Práticos

### 1. Feature completa (orquestração)

```
@supervisor "Criar funcionalidade de login (banco + backend + frontend + testes)"
```

O supervisor orquestra o pipeline com handoff silencioso:
```
@supervisor → @banco (schema/migration)
    → @backend (endpoint + auth)
    → @frontend (tela)
    → @testes (testes do fluxo)
    → @qualidade (revisão)
    → @seguranca (auditoria de auth)
    → supervisor (aprova)
```

### 2. Discovery de domínios

```
@descoberta "Executar discovery pipeline para este projeto"
```

Gera agentes de domínio específicos do projeto (10 fases obrigatórias).

### 3. Design com marca

```
@design "Landing page estilo Linear usando o design-system"
```

Lê `design-systems/linear/DESIGN.md` → gera protótipo → passa ao `@frontend`.

### 4. IA FREE

```
@9router "gerar imagem de post para Instagram"
@ia "transcrever audio.mp3"
@marketing "estratégia de conteúdo para SaaS"
```

---

## 🛠 Troubleshooting

| Problema | Solução |
|----------|---------|
| Agents não aparecem no Tab | Reinicie o OpenCode (agents carregam no startup) |
| Agent não carrega skill | Verifique `skill({ "name": "agent-X" })` no markdown; skill existe em `~/.config/opencode/skills/` |
| 9Router não responde | `curl $NINEROUTER_URL/api/health`; inicie o 9Router em localhost:20128 |
| Skills não encontradas | Confirme que estão em `~/.config/opencode/skills/<nome>/SKILL.md` |
| Config sobrescrito | Restaure do backup: `~/.config/opencode/opencode.jsonc.bak.*` |
| Permissões de bash | Agents usam `bash: allow` — ajuste no `permission` do markdown se necessário |

---

## 📚 Fontes Integradas

| Fonte | Contribuição |
|-------|-------------|
| [everything-claude-code](https://github.com/WorldFlowAI/everything-claude-code) | 3 agents + 11 skills + regras |
| [open-design](https://github.com/nexu-io/open-design) | @design + 9 skills + 153 design-systems |
| [obra/superpowers](https://github.com/obra/superpowers) | 14 skills de processo + plugin |
| [anthropics/skills](https://github.com/anthropics/skills) | skill-creator, pdf, pptx, docx, xlsx, frontend-design |
| [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | web-design-guidelines |
| [stripe/ai](https://github.com/stripe/ai) | stripe-best-practices |
| [andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) | 4 regras de disciplina |

---

## 📄 Licença

MIT — use, modifique e contribua à vontade.

---

**Feito com ❤️ para a comunidade OpenCode.** Dê ⭐ se ajudou!
