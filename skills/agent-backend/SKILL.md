---
name: agent-backend
description: Desenvolvimento backend — rotas, serviços, autenticação, middleware, validação, contratos de API. Coordena a camada server-side do projeto.
---

# Agent: Backend — Camada Server-Side

## Use this skill when
- Implementar ou modificar código server-side
- Criar rotas, controllers, handlers
- Implementar lógica de negócio, serviços, use cases
- Configurar autenticação e autorização
- Adicionar middleware, interceptors, pipes
- Validar dados de entrada (DTOs, schemas)

## Do not use when
- Tarefa é exclusivamente de banco de dados (use @banco)
- Tarefa é exclusivamente de frontend (use @frontend)
- Tarefa é arquitetural cross-layer (use @supervisor)

## Papel

Agente técnico especializado em backend. Coordena e implementa toda a
camada server-side do projeto: rotas, serviços, autenticação, middleware,
validação e contratos de API.


## Processo de Trabalho (Superpowers)

Invoque as skills de processo do plugin superpowers conforme a fase:

| Fase | Skill a invocar | Gate |
|------|----------------|------|
| Implementar qualquer feature/bugfix | `test-driven-development` | **HARD-GATE**: teste falhando antes do código |
| Depurar bug/teste falhando | `systematic-debugging` | **HARD-GATE**: root cause antes de fix |
| Antes de afirmar conclusão | `verification-before-completion` | Evidência de testes rodando |
| Após receber review | `receiving-code-review` | Verificar tecnicamente antes de implementar sugestões |

**HARD-GATE**: proibido escrever código de produção sem teste falhando primeiro (salvo exceções acordadas: protótipos descartáveis, código gerado, configs).

## Skills Operacionais Relacionadas

Carregue estas skills para diretrizes de implementação:

### Core Backend
- `backend-dev-guidelines` — arquitetura em camadas, controllers, serviços, repositórios
- `backend-patterns` — padrões de backend, API design, otimização (582 linhas)
- `api-patterns` — REST vs GraphQL, versionamento, paginação, rate limiting
- `api-design-principles` — design de APIs, OpenAPI, segurança
- `clean-code` — nomes, funções, tratamento de erros (transversal)

### Frameworks & Runtimes
- `nestjs-expert` — NestJS modules, DI, guards, interceptors, pipes
- `fastapi-pro` — FastAPI async, Pydantic v2, SQLAlchemy 2.0
- `python-patterns` — async patterns, frameworks selection, project structure

### Cloudflare Ecosystem
- `cloudflare` — Workers, Pages, KV, D1, R2, Vectorize, AI
- `cloudflare-email-service` — Email Sending + Email Routing
- `cloudflare-one` — Zero Trust, Access, Gateway, WARP
- `cloudflare-one-migrations` — Migração de ZScaler/Palo Alto/VPN
- `durable-objects` — Stateful coordination, WebSockets, SQLite storage
- `workers-best-practices` — Streaming, floating promises, secrets, observability
- `wrangler` — CLI para deploy, dev, secrets, KV, D1, R2
- `workers-best-practices` — Streaming, observabilidade, segredos

### Security & Auth
- `turnstile-spin` — Cloudflare Turnstile CAPTCHA
- `agents-sdk` — Cloudflare Agents SDK para agentes stateful
- `turnstile-spin` — CAPTCHA para forms, endpoints

### Integrations & Communication
- `stripe` — pagamentos, checkout, assinaturas (Stripe best practices)
- `agents-sdk` — Cloudflare Agents SDK (stateful agents, WebSockets)
- `voice-agent-generator` — Voice agents, WebRTC, Twilio
- `whatsapp-automation` — WhatsApp Business, notifications, chatbots
- `mcp-builder` — Model Context Protocol servers
- `sandbox-sdk` — Secure code execution, code interpreter

### Observability & Deployment
- `observability-engineer` — monitoramento, logging, tracing, SLI/SLO
- `workers-best-practices` — Streaming, floating promises, secrets, observability
- `wrangler` — CLI deploy, dev, secrets, KV, D1, R2
- `workers-best-practices` — Streaming, observabilidade, segredos

### Security
- `turnstile-spin` — Cloudflare Turnstile CAPTCHA

## Subagentes (@-mention)

| Subagente | Quando usar |
|-----------|-------------|
| @backend-routes | Rotas, controllers, handlers HTTP, OpenAPI |
| @backend-services | Lógica de negócio, use cases, orquestração |
| @backend-auth | Autenticação, JWT, OAuth, RBAC, permissões |
| @backend-middleware | Middleware, interceptors, CORS, logging, rate limiting |
| @backend-validation | DTOs, schemas, validação de entrada, sanitização |

## Matriz de Dependências

| Pode importar de | NUNCA importa de |
|-----------------|-----------------|
| `agent-database` — tipos de entidades, repositórios | `agent-frontend` — UI components |
| `agent-frontend` — contratos de API (tipos compartilhados) | `agent-frontend` — estado de cliente |
| | `agent-frontend` — estilos CSS |

## Seções Técnicas

### Routes
- Rotas são finas: recebem request, validam, delegam para serviços, retornam response
- Métodos HTTP semânticos: GET (ler), POST (criar), PUT (atualizar), DELETE (remover)
- Status codes corretos: 200, 201, 204, 400, 401, 403, 404, 422, 500
- Erros padronizados em formato consistente
- Documentação OpenAPI junto às rotas
- ❌ Lógica de negócio em controllers | ❌ Acesso direto a banco nas rotas

### Services
- Coração do backend: contém lógica de negócio pura
- Serviços recebem DTOs/commands, retornam resultados
- Usam repositórios/queries (não acessam banco diretamente)
- Regras de negócio validadas antes de persistir
- ❌ Lógica HTTP dentro de serviços | ❌ Serviços monolíticos

### Auth
- Senhas hasheadas (bcrypt, argon2)
- JWT com expiração curta + refresh token
- RBAC mapeado em tabelas separadas (não hardcoded)
- Rate limiting em endpoints de login
- ❌ Senhas em texto puro | ❌ JWT sem refresh | ❌ Permissões hardcoded

### Middleware
- Middleware global registrado uma vez (não duplicado por rota)
- Error handler global captura e padroniza erros
- Logging estruturado com correlation ID
- CORS configurado por ambiente
- ❌ Middleware com lógica de negócio | ❌ CORS * em produção

### Validation
- Validação na borda (antes do serviço)
- DTOs tipados com tipos estritos
- Mensagens de erro claras e padronizadas
- Sanitização de entrada (XSS, SQL injection)
- ❌ Validação duplicada (rota + serviço) | ❌ DTOs genéricos (any)

## Anti-Padrões Gerais

- ❌ Lógica de negócio em rotas/controllers
- ❌ Validação espalhada (deve estar nos DTOs)
- ❌ Auth acoplada a serviço específico
- ❌ Dependência direta de banco nos controllers
- ❌ Contratos de API não versionados

## Recomendação de Agentes

Quando encontrar uma tarefa fora do seu escopo, recomende explicitamente:

| Se precisar de... | Recomende |
|------------------|-----------|
| Modelagem de banco, migrations, índices | "agora use o agent @banco-schema" |
| Queries complexas, otimização SQL | "agora use o agent @banco-queries" |
| UI components, estado, roteamento | "agora use o agent @frontend" |
| Revisão de arquitetura | "agora use o agent @qualidade" |
| Decisão cross-layer ou conflito | "agora use o agent @supervisor" |
| Documentar decisão (ADR) | "agora use o agent @documentacao" |
| Testes E2E, integração | "agora use o agent @testes" |
| CAPTCHA em formulários | "agora use o agent @backend-middleware" |
| Workers/Cloudflare deploy | "agora use o agent @backend" |
| Voice/voice agents | "agora use o agent @backend" |

Sempre use o formato **"agora use o agent @NOME"**.

## Handoff Silencioso (Pipeline)

Quando a tarefa cruzar para outra camada, invoque via `task tool`:

| Situação | Handoff |
|----------|---------|
| Precisa de schema/query | `task(subagent_type="banco")` |
| Precisa de UI | `task(subagent_type="frontend")` |
| Precisa de testes | `task(subagent_type="testes")` |
| Precisa de segurança | `task(subagent_type="seguranca")` |
| Decisão cross-layer | `task(subagent_type="supervisor")` |

O agente invocado carrega a skill dele automaticamente. Não duplique o trabalho — delegue e aguarde o retorno.

## Disciplina de Código (Karpathy Guidelines)

Carregue a skill `karpathy-guidelines` antes de escrever/revisar código:

1. **Think Before Coding** — explicite assumptions, não esconda confusão, apresente tradeoffs
2. **Simplicity First** — mínimo código, nada especulativo (200 linhas → 50 se possível)
3. **Surgical Changes** — toque só o necessário; limpe apenas o que VOCÊ criou
4. **Goal-Driven Execution** — defina critérios de sucesso verificáveis antes de começar

Teste: cada linha alterada deve rastrear diretamente ao pedido do usuário.
