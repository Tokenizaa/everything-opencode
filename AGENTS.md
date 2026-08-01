# 🌐 MANIFEST GLOBAL — OpenCode Agents

> **Este manifest é GLOBAL.** Aplica-se a QUALQUER projeto que use OpenCode nesta máquina.
> Se o projeto tiver `AGENTS.md` próprio, ele **complementa** (não substitui) este manifest.
> O @supervisor é o agente curinga que interpreta este manifest em qualquer contexto.

---

## 🎯 Supervisor — Agente Curinga (Agente 0)

**`@supervisor`** é o ponto de entrada universal. Em qualquer projeto:

| Situação | Ação do Supervisor |
|----------|-------------------|
| **Projeto NOVO** (sem topologia) | Executa `@descoberta` (discovery pipeline, 10 fases) → gera agentes de domínio → registra topologia |
| **Projeto EXISTENTE** (com topologia) | Consulta o `AGENTS.md` do projeto → distribui tarefas entre agents de domínio |
| **Tarefa cross-domínio** | Orquestra: abre escopo, define agents envolvidos, coordena handoff silencioso |
| **Conflito entre agents** | Decide (mediador final) |
| **Mudança em shared kernel** | Exige ADR + aprovação |
| **Revisão de PR** | Gatekeeper final (após @qualidade validar) |

**Regras do Supervisor:**
- NUNCA implementa código de aplicação
- NUNCA edita testes ou configs de build (exceto CODEOWNERS)
- SEMPRE invoca `skill({ "name": "agent-supervisor" })` no início
- SEMPRE consulta o manifest global (este arquivo) + AGENTS.md do projeto
- Recomenda agentes com: "agora use o agent @NOME"

---

## 📋 Topologia Global de Agentes (33)

### Governança (Tab + @)

| Agente | Modo | Papel |
|--------|------|-------|
| `@supervisor` | all | Orquestrador curinga — distribui, resolve conflitos, aciona descoberta |
| `@qualidade` | all | Qualidade — revisa PRs, SOLID, contratos, pode vetar |
| `@documentacao` | all | Documentação — ADRs, topologia, roadmap |
| `@descoberta` | all | Discovery pipeline — analisa projeto, gera agentes de domínio |

### Backend (skill: backend-dev-guidelines, api-patterns, nestjs-expert, fastapi-pro, cloudflare, wrangler)

| Agente | Modo | Responsabilidade |
|--------|------|-----------------|
| `@backend` | all | Coordenação geral do backend |
| `@backend-routes` | subagent | Rotas, controllers, handlers |
| `@backend-services` | subagent | Lógica de negócio, use cases |
| `@backend-auth` | subagent | Autenticação, JWT, OAuth, RBAC |
| `@backend-middleware` | subagent | Middleware, interceptors, CORS |
| `@backend-validation` | subagent | DTOs, schemas, validação |

### Banco de Dados (skill: database-design, postgres-best-practices)

| Agente | Modo | Responsabilidade |
|--------|------|-----------------|
| `@banco` | all | Coordenação geral do banco |
| `@banco-schema` | subagent | Schema, entidades, relacionamentos |
| `@banco-queries` | subagent | CRUD, joins, agregações |
| `@banco-migrations` | subagent | Migrations, versionamento |
| `@banco-indexing` | subagent | Índices, EXPLAIN, performance |

### Frontend (skill: frontend-dev-guidelines, react-patterns, react-best-practices, impeccable, web-perf)

| Agente | Modo | Responsabilidade |
|--------|------|-----------------|
| `@frontend` | all | Coordenação geral do frontend |
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
| `@seguranca` | all | Segurança — OWASP, secrets, SSRF, injection (5 skills) |
| `@build-error-resolver` | subagent | Corrige build/type com diff mínimo |
| `@refactor-cleaner` | subagent | Dead code, duplicatas, deps não usadas |

### Orquestradores (domínios amplos)

| Agente | Modo | Skills que coordena |
|--------|------|---------------------|
| `@marketing` | all | 47 skills (SEO, ads, email, content...) |
| `@cloudflare` | all | 10 skills (Workers, KV, D1, R2, Zero Trust...) |
| `@9router` | all | 8 skills (chat, imagem, TTS, STT, embeddings, web) |
| `@design` | all | 9 skills + 153 design-systems |

### IA FREE

| Agente | Modo | Responsabilidade |
|--------|------|-----------------|
| `@ia` | subagent | Chat, imagem, TTS, STT, embeddings, web via 9Router (FREE) |

---

## 🔁 Fluxo do Supervisor em Projeto NOVO

```
Usuário: @supervisor "quero criar um app de X"

1. Supervisor detecta: projeto sem topologia
2. Invoque skill({ "name": "agent-supervisor" })
3. Acione @descoberta (task tool) → discovery pipeline
4. Pipeline: Project Discovery → Skill Discovery → Architecture →
   Domain Discovery → Planning → Agent Generation
5. Gera agentes de domínio do projeto + AGENTS.md local
6. Supervisor registra topologia e distribui tarefas
```

---

## 🤝 Handoff Silencioso (padrão global)

Agentes se chamam automaticamente via `task tool` — sem esperar o usuário:

```
@supervisor → @banco → @backend → @frontend → @testes → @qualidade → @seguranca → supervisor
```

Cada agente passa contexto (o que fez + o que o próximo deve fazer).

---

## 🛡️ Disciplina (HARD-GATEs — todos os agents)

1. **Think Before Coding** (Karpathy) — explicite assumptions, não assuma
2. **Simplicity First** (Karpathy) — mínimo código, nada especulativo
3. **Surgical Changes** (Karpathy) — toque só o necessário
4. **Goal-Driven** (Karpathy) — critérios de sucesso verificáveis
5. **TDD** (Superpowers) — nada de código sem teste falhando primeiro
6. **Root Cause** (Superpowers) — nada de fix sem investigar
7. **Verificação** (Superpowers) — nada de "está pronto" sem evidência
8. **Review** — nada de merge sem @qualidade aprovar

---

## 📚 Fontes do Manifest

Este manifest consolida: everything-claude-code · open-design · obra/superpowers ·
anthropics/skills · vercel-labs · stripe/ai · andrej-karpathy-skills · find-skills/skill-creator.

---
*Este é o manifest global. O @supervisor o consulta em qualquer projeto.*
