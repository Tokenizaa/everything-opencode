---
name: agent-architecture-test
description: Teste HARD do PROJETO — analisa stack, arquitetura, domínios, backend, banco, frontend, qualidade, segurança e performance do código. Gera relatório de saúde do projeto (0-100). Use quando o usuário pedir "teste hard", "análise do projeto", "auditoria do projeto", "health check do projeto".
---

# Teste HARD do Projeto

Auditoria completa e executável do **código do projeto** (não da estrutura de agents).
Analisa stack, arquitetura, domínios, camadas, qualidade, segurança e performance.
Gera relatório de saúde do projeto com health check 0-100.

## Quando usar

- Usuário pede "teste hard", "análise do projeto", "auditoria do projeto"
- Antes de uma refatoração grande
- Onboarding em projeto existente
- Health check periódico da base de código

## Parte 1 — Inventário (Project Discovery)

### 1.1 Identificação
- Linguagem primária / secundárias
- Framework(s) principal(is)
- Package manager (npm/pnpm/yarn/bun/poetry/cargo...)
- Versionamento (git branch default, commits recentes)

### 1.2 Estrutura
- Diretórios raiz e sua função (src/, app/, api/, tests/, docs/...)
- Monorepo? (workspaces, packages/)
- Arquivos de config (tsconfig, eslint, docker, CI)

### 1.3 Documentação
- README, AGENTS.md, docs/, ADRs
- Cobertura de documentação

## Parte 2 — Arquitetura (Architecture Discovery)

### 2.1 Camadas e Módulos
- Padrão arquitetural (MVC, clean, hexagonal, modular monolith...)
- Camadas: apresentação / aplicação / domínio / infraestrutura
- Módulos/features e suas fronteiras

### 2.2 Dependências
- Grafo de dependências entre módulos
- Dependências circulares?
- Shared kernel / módulos centrais
- Módulos isolados / órfãos

### 2.3 Acoplamento
- Fan-in / fan-out por módulo
- Importações cruzadas entre camadas (UI → DB direto?)
- Violações de camada

## Parte 3 — Backend e APIs

### 3.1 Endpoints
- Rotas/controllers listados
- Métodos HTTP, autenticação por rota
- Validação de entrada (DTOs/schemas)

### 3.2 Services
- Lógica de negócio isolada?
- Use cases claros?
- Tratamento de erros consistente?

### 3.3 Integrações
- APIs externas, SDKs, webhooks
- Autenticação externa (OAuth, JWT)
- Edge Functions / serverless (se aplicável)

## Parte 4 — Banco de Dados

### 4.1 Schema
- Entidades/tabelas, relacionamentos
- Migrations versionadas?
- Índices em FKs e colunas de busca?

### 4.2 Segurança de dados
- RLS (row level security) habilitado? (Supabase/Postgres)
- Queries parametrizadas?
- Secrets em env vars (não hardcoded)?

## Parte 5 — Frontend

### 5.1 Componentes
- Componentes reutilizáveis / monolíticos
- Estados (loading, empty, error) presentes?
- Acessibilidade básica?

### 5.2 Estado e Dados
- Gerenciamento de estado (local/global/server)
- Data fetching padronizado (query lib)?
- Cache e invalidação?

## Parte 6 — Qualidade

### 6.1 Código
- Lint: erros/warnings atuais
- Typecheck: passa?
- `any` excessivo / tipos soltos
- Duplicação de código
- Complexidade (funções gigantes)

### 6.2 Testes
- Framework de testes presente?
- Suíte existente: unit / integração / E2E
- Cobertura aproximada (se mensurável)
- Testes rodando: passa?

### 6.3 Dead Code
- Arquivos/imports não usados
- Dependências órfãs

## Parte 7 — Segurança

- Secrets no código? (grep api_key, password, token)
- Input validation nas rotas públicas
- Headers de segurança / CORS
- Dependências com vulnerabilidades (audit)
- Auth/authorization em toda rota protegida

## Parte 8 — Performance

- Build: tempo, warnings, tamanho bundle (se mensurável)
- Padrões de performance (lazy loading, memo, queries N+1)
- Assets grandes / não otimizados

## Parte 9 — Relatório Final Obrigatório

```markdown
## 📊 RELATÓRIO DE TESTE HARD — <PROJETO>

### 1. Resumo Executivo
- Stack identificada / arquitetura / domínios
- VEREDITO: ✅ SAUDÁVEL / ⚠️ ATENÇÃO / ❌ CRÍTICO

### 2. Inventário
- Linguagem, framework, package manager, estrutura

### 3. Arquitetura
- Padrão, camadas, módulos, acoplamento, circular?

### 4. Backend / APIs
- Endpoints, validação, services, integrações

### 5. Banco de Dados
- Schema, migrations, índices, RLS

### 6. Frontend
- Componentes, estado, data fetching

### 7. Qualidade
- Lint, typecheck, testes, cobertura, dead code

### 8. Segurança
- Secrets, validação, vulnerabilidades

### 9. Performance
- Build, bundle, padrões

### 10. Health Check do Projeto (0-100)
| Área | Peso | Nota |
|------|------|------|
| Arquitetura | 20 | X |
| Backend/API | 15 | X |
| Banco de Dados | 15 | X |
| Frontend | 15 | X |
| Qualidade/Testes | 20 | X |
| Segurança | 15 | X |
| **TOTAL** | 100 | **X/100** |

### 11. Recomendações (top 5)
1. [prioridade mais alta primeiro]
```

## Regras Absolutas

- Basear TUDO em evidência real (ler código, rodar comandos)
- NUNCA afirmar sem verificar (verification-before-completion)
- Reportar problemas honestamente (não suavizar)
- Se algo não for mensurável, dizer "não mensurável" (não inventar)
- O relatório é o entregável PRINCIPAL

## Handoff

| Situação | Handoff |
|----------|---------|
| Precisar implementar correção | `task(subagent_type="backend")` / agent da camada |
| Banco de dados | `task(subagent_type="banco")` |
| Frontend | `task(subagent_type="frontend")` |
| Testes | `task(subagent_type="testes")` |
| Segurança | `task(subagent_type="seguranca")` |

## Recomendação de Agentes

| Se precisar de... | Recomende |
|------------------|-----------|
| Implementar | "agora use o agent @backend" |
| Banco | "agora use o agent @banco" |
| Testes | "agora use o agent @testes" |

Sempre use o formato **"agora use o agent @NOME"**.
