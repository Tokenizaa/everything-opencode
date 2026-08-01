---
name: agent-all
description: Visão geral de todos os agents disponíveis, topologia e como escolher. Carregue para saber qual agent usar ou entender a arquitetura multi-agente.
---

# Agent Architecture — Todos os Agents

## Use this skill when
- Quer visão geral de todos os agents disponíveis
- Não sabe qual agent usar para uma tarefa
- Quer entender a arquitetura multi-agente antes de começar

## Do not use when
- Já sabe qual agent usar — carregue a skill específica diretamente
- Tarefa de implementação pura (vá direto ao agente)

## Agentes de Governança (Sempre Presentes)

Estes agentes existem em qualquer projeto e são independentes de domínio.

| # | Agente | Modo | Papel |
|---|--------|------|-------|
| 0 | @supervisor | primary | Orquestração — distribui tarefas, resolve conflitos, discovery |
| — | @qualidade | primary | Qualidade — revisa PRs, valida SOLID, contratos, pode vetar |
| — | @documentacao | primary | Documentação — ADRs, topologia, folder-structure, roadmap |
| — | @descoberta | primary | Discovery pipeline — analisa projeto, descobre domínios, gera agentes |

## Agentes Técnicos por Camada (Sempre Disponíveis)

Agentes especializados por camada tecnológica, disponíveis via `@`.
Cada um referencia skills operacionais para diretrizes de implementação.

### Backend — `skill backend-dev-guidelines, api-patterns, nestjs-expert, fastapi-pro, cloudflare, wrangler, workers-best-practices`

| Agente | Responsabilidade |
|--------|-----------------|
| @backend | Coordenação geral do backend |
| @backend-routes | Rotas, controllers, handlers, OpenAPI |
| @backend-services | Lógica de negócio, use cases |
| @backend-auth | Autenticação, JWT, OAuth, RBAC |
| @backend-middleware | Middleware, interceptors, CORS, logging |
| @backend-validation | DTOs, schemas, validação |

**Skills operacionais**: `backend-dev-guidelines`, `api-patterns`, `api-design-principles`, `nestjs-expert`, `fastapi-pro`, `cloudflare`, `cloudflare-email-service`, `cloudflare-one`, `durable-objects`, `workers-best-practices`, `wrangler`, `turnstile-spin`, `agents-sdk`, `voice-agent-generator`, `whatsapp-automation`, `sandbox-sdk`, `mcp-builder`

### Banco de Dados — `skill database-design, postgres-best-practices`

| Agente | Responsabilidade |
|--------|-----------------|
| @banco | Coordenação geral do banco |
| @banco-schema | Schema, entidades, relacionamentos |
| @banco-queries | CRUD, joins, agregações |
| @banco-migrations | Migrations, versionamento, rollback |
| @banco-indexing | Índices, EXPLAIN, performance |

**Skills operacionais**: `database-design`, `postgres-best-practices`

### Frontend — `skill frontend-dev-guidelines, react-patterns, react-best-practices, impeccable, web-perf`

| Agente | Responsabilidade |
|--------|-----------------|
| @frontend | Coordenação geral do frontend |
| @frontend-components | UI components, composição, a11y |
| @frontend-state | Estado local, global, server state |
| @frontend-routing | Rotas client-side, layouts, guards |
| @frontend-styling | Estilos, theming, design tokens |

**Skills operacionais**: `frontend-dev-guidelines`, `react-patterns`, `react-best-practices`, `impeccable`, `web-perf`, `playwright-cli`, `react-native-architecture`

### Testes — `skill e2e-testing-patterns, python-testing-patterns, playwright-cli, web-perf`

| Agente | Responsabilidade |
|--------|-----------------|
| @testes | Estratégia e coordenação de testes |
| @testes-unit | Testes unitários, mocks, isolamento |
| @testes-integracao | Testes de integração entre camadas |
| @testes-e2e | Testes end-to-end, Playwright/Cypress |
| @testes-performance | Testes de carga e performance |

**Skills operacionais**: `e2e-testing-patterns`, `python-testing-patterns`, `playwright-cli`, `web-perf`


## Agentes Especializados (Qualidade & Manutenção)

| Agente | Modo | Responsabilidade |
|--------|------|-----------------|
| @seguranca | primary | Segurança — OWASP Top 10, secrets, SSRF, injection |
| @build-error-resolver | subagent | Corrige erros de build/type com diffs mínimos |
| @refactor-cleaner | subagent | Dead code, duplicatas, dependências não usadas |

**Skills**: `agent-security-review`, `agent-build-fix`, `agent-refactor`



## Agente de Design

| Agente | Modo | Responsabilidade |
|--------|------|-----------------|
| @design | all | Design — direção criativa, DESIGN.md, protótipos, decks, design systems |

## Agentes Orquestradores

| Agente | Modo | Responsabilidade |
|--------|------|-----------------|
| @marketing | all | Marketing — estratégia, conteúdo, SEO, ads, email, growth (47 skills) |
| @cloudflare | all | Cloudflare — Workers, Pages, KV, D1, R2, DO, Zero Trust |
| @9router | all | IA via 9Router — chat, imagem, TTS, STT, embeddings, web (FREE) |

## Agentes de Domínio (Gerados por Discovery)

Além dos agents de governança e técnicos, cada projeto pode ter **agentes de domínio dinâmicos**,
gerados automaticamente pelo discovery pipeline.

Para descobrir os agents de domínio de um projeto, execute:

```
@descoberta "Executar discovery pipeline para este projeto"
```

Ou consulte o `AGENTS.md` do projeto para ver a topologia atual.

## Skills Operacionais Relacionadas

Skills complementares que fornecem diretrizes de implementação detalhadas:

| Skill | Referenciada por |
|-------|-----------------|
| `backend-dev-guidelines` | Backend (arquitetura em camadas, controllers, serviços) |
| `api-patterns` | Backend (REST vs GraphQL, versionamento) |
| `api-design-principles` | Backend (design de APIs, OpenAPI) |
| `database-design` | Database (seleção de banco, ORM, normalização) |
| `postgres-best-practices` | Database (performance, EXPLAIN, RLS) |
| `frontend-dev-guidelines` | Frontend (Suspense, TanStack Router, MUI) |
| `react-patterns` | Frontend (componentes, hooks, estado) |
| `react-best-practices` | Frontend (performance React/Next.js) |
| `clean-code` | Todos (qualidade de código transversal) |
| `e2e-testing-patterns` | Testing, Frontend (testes Playwright/Cypress) |
| `python-testing-patterns` | Testing (pytest, fixtures, async) |
| `web-perf` | Frontend, Testing (Core Web Vitals, Lighthouse) |
| `impeccable` | Frontend (UI design, tokens, theming) |
| `playwright-cli` | Testing, Frontend (browser automation) |
| `nestjs-expert` | Backend (NestJS modules, DI, guards) |
| `fastapi-pro` | Backend (FastAPI async, Pydantic v2) |
| `cloudflare` | Backend (Workers, Pages, KV, D1, R2) |
| `wrangler` | Backend (CLI deploy, dev, KV, D1, R2) |
| `workers-best-practices` | Backend (streaming, observabilidade) |
| `cloudflare-email-service` | Backend (Email Sending + Routing) |
| `cloudflare-one` | Backend (Zero Trust, Access, Gateway) |
| `durable-objects` | Backend (stateful coordination, WebSockets) |
| `workers-best-practices` | Backend (streaming, observabilidade) |
| `turnstile-spin` | Backend (CAPTCHA) |
| `agents-sdk` | Backend (stateful agents, WebSockets) |
| `voice-agent-generator` | Backend (voice agents, WebRTC) |
| `whatsapp-automation` | Backend (WhatsApp Business, chatbots) |
| `sandbox-sdk` | Backend (code execution, interpreter) |
| `mcp-builder` | Backend (MCP servers) |
| `impeccable` | Frontend (UI design, tokens, theming) |
| `web-perf` | Frontend, Testing (Core Web Vitals, Lighthouse) |
| `playwright-cli` | Testing, Frontend (browser automation) |
| `react-native-architecture` | Frontend (React Native, Expo) |
| `clean-code` | Todos (qualidade de código transversal) |
| `e2e-testing-patterns` | Testing, Frontend (Playwright/Cypress) |
| `python-testing-patterns` | Testing (pytest, fixtures, async) |
| `web-perf` | Frontend, Testing (Core Web Vitals, Lighthouse) |

## Como Usar

```markdown
@supervisor
"Executar discovery pipeline para o projeto em /caminho/do/projeto"
```

```markdown
@qualidade
"Revisar PR #42 — validar arquitetura e acoplamento"
```

```markdown
@documentacao
"Criar ADR para a decisão de migrar de REST para GraphQL"
```

```markdown
@backend
"Implementar CRUD de usuários com autenticação JWT"
```

```markdown
@banco
"Otimizar query de relatório mensal"
```

```markdown
@frontend
"Criar página de perfil do usuário"
```

```markdown
@testes
"Criar testes E2E para fluxo de checkout"
```

## Regras Invioláveis (Todos os Agents)

1. **Think Before Coding** (Karpathy) — explicite assumptions, não assuma
2. **Simplicity First** (Karpathy) — mínimo código, nada especulativo
3. **Surgical Changes** (Karpathy) — toque só o necessário
4. **Goal-Driven** (Karpathy) — critérios de sucesso verificáveis antes de começar
5. **Não editar fora do seu escopo** sem autorização do Supervisor
2. **Nunca criar dependências circulares** entre módulos
3. **Nunca duplicar lógica** — reutilizar componentes existentes
4. **Toda integração externa** passa por camada de integração dedicada
5. **Não introduzir arquitetura enterprise** sem justificativa em ADR
6. **Tipos de domínio são contratos** — mudanças exigem ADR
7. **Header `// @owner`** em arquivos críticos sinaliza o dono


## Processo Simbiótico (Superpowers)

Nossas skills definem **quem faz** e **onde**; as superpowers skills definem
**como** o trabalho é executado. Referencie as skills de processo conforme a fase:

```
@supervisor: brainstorming → writing-plans → dispatching-parallel-agents
    ↓
@backend/@frontend/@banco: test-driven-development (teste antes do código)
    ↓
@testes: verification-before-completion (evidência antes de afirmar pronto)
    ↓
@qualidade: requesting-code-review → verification-before-completion
    ↓
@supervisor: finishing-a-development-branch (integrar com testes verdes)
```

**HARD-GATEs simbióticos:**
1. **Nada de código sem teste falhando primeiro** (test-driven-development) — salvo protótipos descartáveis/configs acordados
2. **Nada de fix sem root cause** (systematic-debugging)
3. **Nada de "está pronto" sem evidência** (verification-before-completion)
4. **Nada de merge sem review** (requesting-code-review → @qualidade)

As superpowers skills NÃO são duplicadas aqui — são invocadas via `skill tool`
do plugin instalado (obra/superpowers).

## Fluxo de Trabalho

```
Supervisor → aciona discovery pipeline se necessário
  ↓
Discovery Pipeline → analisa projeto, detecta domínios, gera agentes
  ↓
Supervisor → distribui tarefas entre agents de domínio gerados
  ↓
Agente de Domínio → implementa em seu escopo
  ↓
Architecture Review → valida arquitetura, acoplamento, duplicação
  ↓
Supervisor → aprova merge
  ↓
Context Agent → atualiza docs, ADRs, topologia
```

## Shared Kernel (Zona de Cuidado)

Todo projeto pode ter um shared kernel — conjunto de tipos, utilitários e estado
compartilhados entre domínios. Mudanças no shared kernel exigem:
- ADR obrigatório
- Aprovação do Supervisor
- Revisão do Architecture Review
