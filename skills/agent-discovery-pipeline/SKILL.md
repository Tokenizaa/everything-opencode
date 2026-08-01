---
name: agent-discovery-pipeline
description: Pipeline orquestrador de descoberta. Analisa projeto, descobre estrutura/arquitetura/domínios, gera agentes. 10 fases obrigatórias.
---

# Skill: Agent Discovery Pipeline

## Use this skill when
- Executar o discovery pipeline completo para um projeto
- Iniciar um novo projeto do zero — descobrir estrutura, arquitetura, domínios
- Reanalisar projeto após mudanças estruturais significativas
- Gerar/regerar topologia de agentes para um projeto

## Do not use when
- Apenas precisa de uma fase isolada (carregue a skill específica)
- Projeto já tem topologia definida e não houve mudanças
- Precisa implementar código (vá ao agente de domínio apropriado)

## Papel

Pipeline orquestrador que executa **todas as fases do discovery em sequência
obrigatória**. Nenhuma fase pode ser pulada. O pipeline analisa o projeto,
descobre sua estrutura, arquitetura e domínios, e gera agentes especializados.

## Fluxo Obrigatório

```
Fase 1 — Project Discovery
    ↓
Fase 2 — Skill Discovery (find-skills)
    ↓
Fase 3 — Skill Creation (se necessário)
    ↓
Fase 4 — Architecture Discovery
    ↓
Fase 5 — Domain Discovery
    ↓
Fase 6 — Planning
    ↓
Fase 7 — Agent Generation
    ↓
Fase 8 — Execution (recomendar ao Supervisor)
    ↓
Fase 9 — Review (acionar Architecture Review)
    ↓
Fase 10 — Validation
```

**NENHUMA FASE PODE SER PULADA.**

## Parâmetros

| Parâmetro | Obrigatório | Descrição |
|-----------|-------------|-----------|
| `project_root` | Sim | Caminho absoluto para a raiz do projeto |
| `output_dir` | Não | Onde salvar outputs intermediários (default: `/tmp/discovery-{timestamp}`) |
| `force_rediscovery` | Não | Se `true`, ignora cache e rediscovery completo |

## Fases Detalhadas

### Fase 1 — Project Discovery

**Skill:** `project-discovery`

Carregar a skill `project-discovery` e executar a descoberta completa:

1. Identificar linguagem primária e secundárias
2. Detectar framework e bibliotecas principais
3. Mapear estrutura de diretórios (4 níveis)
4. Detectar monorepo
5. Mapear CI/CD
6. Identificar configurações e ferramentas
7. Analisar documentação

**Output:** Relatório estruturado do projeto (`discovery_report.yml`)

### Fase 2 — Skill Discovery

**Meta-skill:** `find-skills`

Para cada padrão identificado no projeto:
- Framework → há skill para este framework?
- Database → há skill para este banco?
- Padrão arquitetural → há skill?
- Ferramentas → há skills?

Consultar `find-skills` (meta) para verificar skills reutilizáveis.

**Registrar:**
- Skills que existem e serão reutilizadas
- Skills que NÃO existem e precisam ser criadas

### Fase 3 — Skill Creation

**Meta-skill:** `skill-creator`

Para cada skill que não existe (identificada na Fase 2):

1. Carregar `skill-creator`
2. Criar nova skill com:
   - Descrição clara
   - Objetivo
   - Exemplos de uso
   - Boas práticas
   - Limitações
   - Casos de uso

**Output:** Novas skills registradas no diretório de skills

### Fase 4 — Architecture Discovery

**Skill:** `architecture-discovery`

Carregar a skill `architecture-discovery` e analisar:

1. Mapear módulos e suas responsabilidades
2. Analisar dependências entre módulos
3. Identificar serviços, APIs, endpoints
4. Mapear entidades e modelos
5. Listar integrações externas
6. Avaliar acoplamento (fan-in/fan-out)
7. Inferir padrão arquitetural

**Input:** Output da Fase 1 (Project Discovery)
**Output:** Relatório de arquitetura (`architecture_report.yml`)

### Fase 5 — Domain Discovery

**Skill:** `domain-discovery`

Carregar a skill `domain-discovery` e detectar domínios:

1. Agrupar módulos por coesão
2. Identificar bounded contexts
3. Mapear responsabilidades de cada domínio
4. Refinar (split/merge conforme necessário)
5. Nomear domínios usando linguagem ubíqua do projeto

**Input:** Output da Fase 4 (Architecture Discovery)
**Output:** Relatório de domínios (`domains_report.yml`)

### Fase 6 — Planning

Com base nos outputs das fases anteriores:

1. **Definir agentes necessários:**
   - Agents de governança (sempre presentes): Supervisor, Architecture Review, Context Manager
   - Agents de domínio: um para cada domínio descoberto

2. **Definir quantidade ideal de agentes:**
   - Mínimo: 1 por domínio
   - Se domínio muito grande → dividir em sub-agentes
   - Se domínio muito pequeno → mesclar com outro

3. **Definir dependências entre agentes:**
   - Quem depende de quem?
   - Ordem de execução necessária?
   - Paralelismo possível?

4. **Definir shared kernel:**
   - O que é compartilhado entre domínios?
   - Quem pode modificar?
   - Regras de acesso

### Fase 7 — Agent Generation

**Skill:** `agent-generator`

Carregar a skill `agent-generator` e gerar:

1. Para cada domínio:
   - Definir nome, objetivo, escopo
   - Definir arquivos permitidos/proibidos
   - Definir dependências e contratos
   - Definir ferramentas e skills
   - Definir critérios de sucesso/revisão

2. Gerar arquivo `SKILL.md` para cada agente
3. Gerar/atualizar `AGENTS.md` do projeto
4. Registrar skills de agentes no ecossistema

**Input:** Domain + Architecture reports
**Output:** Skills de agente criadas + AGENTS.md

### Fase 8 — Execution (Recomendação)

Com base no planejamento:

1. Gerar lista de tarefas iniciais para cada agente
2. Recomendar ao Supervisor a ordem de execução
3. Identificar tarefas paralelizáveis
4. Estimar dependências e bloqueios

**Nota:** O pipeline não executa as tarefas — apenas recomenda. A execução é
responsabilidade do Supervisor.

### Fase 9 — Review

**Skill:** `agent-architecture-review`

1. Carregar `agent-architecture-review`
2. Revisar os agentes gerados:
   - Escopo sem sobreposição
   - Dependências corretas
   - Contratos bem definidos
   - Skills adequadas
3. Reportar problemas encontrados

### Fase 10 — Validation

Validar o resultado final:

1. **Integridade**: todos os domínios mapeados têm um agente?
2. **Completude**: todas as responsabilidades cobertas?
3. **Isolamento**: nenhum agente invade escopo de outro?
4. **Coesão**: cada agente tem responsabilidade única e clara?
5. **Acoplamento**: dependências entre agentes são mínimas e explícitas?

## Output Final

```yaml
pipeline_result:
  project: "/caminho/do/projeto"
  timestamp: "2026-07-28T12:00:00Z"
  phases:
    project_discovery:
      status: "completed"
      output: "discovery_report.yml"
    skill_discovery:
      status: "completed"
      reused_skills: ["database", "api-patterns"]
      created_skills: []
    architecture_discovery:
      status: "completed"
      output: "architecture_report.yml"
    domain_discovery:
      status: "completed"
      domains_found: 4
      output: "domains_report.yml"
    planning:
      status: "completed"
      agents_planned: 3  # domain agents
    agent_generation:
      status: "completed"
      agents_generated:
        - agent-dominio-usuarios
        - agent-dominio-catalogo
        - agent-dominio-pedidos
      agents_md_updated: true
    review:
      status: "completed"
      blockers: 0
      warnings: 2
    validation:
      status: "completed"
      passed: true
  summary:
    total_agents: 6  # 3 governance + 3 domain
    shared_kernel: true
    architecture_pattern: "modular_monolith"
```

## Gatilhos para Rediscovery

O pipeline deve ser reexecutado quando:

- Novos módulos/diretórios forem adicionados
- A arquitetura mudar significativamente
- Novos domínios surgirem
- Dependências entre módulos mudarem
- O Supervisor detectar que a topologia atual não cobre novas demandas

## Tools OpenCode

- `skill` — carregar skills de cada fase (`project-discovery`, `find-skills`, `skill-creator`, `architecture-discovery`, `domain-discovery`, `agent-generator`, `agent-architecture-review`)
- `read` — ler outputs de fases anteriores
- `write` / `edit` — gerar relatórios intermediários
- `bash` — criar diretórios temporários
- `task` — delegar fases complexas em paralelo
- `glob`, `grep` — consultas auxiliares

## Anti-Padrões

- ❌ Pular qualquer fase do pipeline
- ❌ Executar fases em ordem diferente da especificada
- ❌ Modificar o projeto durante o discovery
- ❌ Assumir domínios sem executar domain-discovery
- ❌ Gerar agentes sem antes consultar find-skills
- ❌ Ignorar shared kernel na definição de fronteiras
