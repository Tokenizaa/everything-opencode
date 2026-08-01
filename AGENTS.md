# Agent Topology — opencode-agents

## Agentes de Governança (Tab + @)

| Agente | Modo | Papel |
|--------|------|-------|
| @supervisor | all | Orquestrador — distribui tarefas, resolve conflitos, aciona descoberta |
| @qualidade | all | Qualidade — revisa PRs, valida SOLID, contratos, pode vetar |
| @documentacao | all | Documentação — ADRs, topologia, folder-structure, roadmap |
| @descoberta | all | Discovery pipeline — analisa projeto, descobre domínios, gera agentes |

## Agentes Técnicos por Camada (Tab + @)

### Backend (skill: backend-dev-guidelines, api-patterns, nestjs-expert, fastapi-pro, cloudflare, wrangler)

| Agente | Modo | Responsabilidade |
|--------|------|-----------------|
| @backend | all | Coordenação geral do backend |
| @backend-routes | subagent | Rotas, controllers, handlers |
| @backend-services | subagent | Lógica de negócio, use cases |
| @backend-auth | subagent | Autenticação, autorização, RBAC |
| @backend-middleware | subagent | Middleware, interceptors, CORS |
| @backend-validation | subagent | DTOs, schemas, validação |

### Banco de Dados (skill: database-design, postgres-best-practices)

| Agente | Modo | Responsabilidade |
|--------|------|-----------------|
| @banco | all | Coordenação geral do banco |
| @banco-schema | subagent | Schema, entidades, relacionamentos |
| @banco-queries | subagent | CRUD, joins, agregações |
| @banco-migrations | subagent | Migrations, versionamento |
| @banco-indexing | subagent | Índices, EXPLAIN, performance |

### Frontend (skill: frontend-dev-guidelines, react-patterns, react-best-practices, impeccable, web-perf)

| Agente | Modo | Responsabilidade |
|--------|------|-----------------|
| @frontend | all | Coordenação geral do frontend |
| @frontend-components | subagent | UI components, composição |
| @frontend-state | subagent | Estado local, global, server state |
| @frontend-routing | subagent | Rotas client-side, layouts |
| @frontend-styling | subagent | Estilos, theming, tokens |

### Testes (skill: e2e-testing-patterns, python-testing-patterns, playwright-cli, web-perf)

| Agente | Modo | Responsabilidade |
|--------|------|-----------------|
| @testes | all | Estratégia e coordenação de testes |
| @testes-unit | subagent | Testes unitários, mocks, isolamento |
| @testes-integracao | subagent | Testes de integração entre camadas |
| @testes-e2e | subagent | Testes end-to-end, Playwright/Cypress |
| @testes-performance | subagent | Testes de carga e performance |

## Agentes Especializados

| Agente | Modo | Responsabilidade |
|--------|------|-----------------|
| @seguranca | all | Segurança — OWASP Top 10, secrets, SSRF, injection |
| @build-error-resolver | subagent | Corrige erros de build/type com diffs mínimos |
| @refactor-cleaner | subagent | Dead code, duplicatas, dependências não usadas |

## Agentes Orquestradores

| Agente | Modo | Responsabilidade |
|--------|------|-----------------|
| @marketing | all | Marketing — estratégia, conteúdo, SEO, ads, email, growth (47 skills) |
| @cloudflare | all | Cloudflare — Workers, Pages, KV, D1, R2, DO, Zero Trust |
| @9router | all | IA via 9Router — chat, imagem, TTS, STT, embeddings, web (FREE) |

## Agente de Design

| Agente | Modo | Responsabilidade |
|--------|------|-----------------|
| @design | all | Design — direção criativa, DESIGN.md, protótipos, decks, design systems |

## Agente de IA (9Router FREE)

| Agente | Modo | Responsabilidade |
|--------|------|-----------------|
| @ia | subagent | Chat, imagem, TTS, STT, embeddings, web search/fetch via 9Router (FREE) |
