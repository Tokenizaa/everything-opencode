---
name: agent-generator
description: Gera agentes de domínio a partir da descoberta. Define escopo, fronteiras, ferramentas e critérios de cada agente.
---

# Skill: Agent Generator

## Use this skill when
- Executar fase 7 do discovery pipeline — gerar agentes de domínio
- Criar definições completas de agentes a partir de domínios descobertos
- Gerar skills de agente para cada bounded context identificado

## Do not use when
- Ainda não executou domain-discovery (necessário como input)
- Precisa executar o pipeline completo (use agent-discovery-pipeline)
- Vai modificar o código do projeto (esta skill gera configuração de agentes)

## Papel

Gera automaticamente agentes especializados para cada domínio descoberto.
Cada agente recebe nome, objetivo, escopo, fronteiras, ferramentas e
critérios — com **zero sobreposição de responsabilidade**.

## Pré-requisito

Antes de executar, deve ter o output do `domain-discovery` disponível.

## Regras

- **Nunca gerar agentes sobrepostos** — cada responsabilidade pertence a UM agente
- **Nunca criar agentes para shared kernel** — isso é governança, não domínio
- **Nunca dividir agentes por tecnologia** — sempre por domínio
- Skills geradas devem ser armazenadas no diretório de skills do OpenCode

## Fases de Geração

### Fase 7.1 — Planejamento de Agentes

Para cada domínio descoberto (excluindo shared kernel), decidir:

1. **Nome do agente** → baseado no nome do domínio
   - Ex: domínio "Usuários" → agente `agent-dominio-usuarios`
   - Ex: domínio "Catálogo" → agente `agent-dominio-catalogo`

2. **Objetivo** → curto, uma frase
   - Ex: "Gerencia tudo relacionado a usuários: cadastro, autenticação, perfis"

3. **Escopo** → quais arquivos/diretórios estão sob responsabilidade do agente
   - Extraído do output do domain-discovery

4. **Dependências** → quais outros agentes/domínios este agente precisa consumir
   - Extraído das dependências entre domínios

### Fase 7.2 — Definição de Fronteiras

Para cada agente, definir:

| Propriedade | Descrição |
|-------------|-----------|
| **Arquivos permitidos** | Diretórios que o agente pode modificar |
| **Arquivos proibidos** | Diretórios de outros domínios que o agente NÃO pode tocar |
| **Pode importar de** | Quais outros domínios pode consumir (via contratos públicos) |
| **NUNCA importa de** | Quais domínios não pode importar |
| **Contratos públicos** | Interfaces, tipos, eventos que EXPÕE para outros domínios |

### Fase 7.3 — Ferramentas e Skills

Para cada agente, definir:

- **Ferramentas autorizadas**: `read`, `write`, `edit`, `glob`, `grep`, `bash`, `task` (com limites)
- **Skills obrigatórias**: skills operacionais necessárias para o domínio
  - Ex: domínio de banco de dados → `database` skill
  - Ex: domínio de API → `api-patterns` skill
- **Skills proibidas**: skills que não fazem sentido para o domínio

### Fase 7.4 — Critérios de Sucesso

Para cada agente, definir:

1. **Critérios de conclusão** — como saber se a tarefa foi concluída
   - Ex: "CRUD de usuários implementado com testes passando"
2. **Critérios de qualidade** — padrões que o código deve seguir
   - Ex: "Validação de email, hash de senha, rate limiting"
3. **Critérios de revisão** — o que o Architecture Review vai verificar
   - Ex: "Não vaza detalhes de banco para outros domínios"

### Fase 7.5 — Geração do Skill de Agente

Criar arquivo `SKILL.md` no diretório da skill com:

```markdown
# Agent: {nome-do-agente}

## Use this skill when
- {lista de situações que ativam este agente}

## Do not use when
- {lista de situações que NÃO ativam este agente}

## Papel

{descrição do papel do agente}

## Diretórios Próprios

- {lista de diretórios que o agente pode modificar}

## Pode Importar de

- {domínios que pode consumir}

## NUNCA Importa de

- {domínios que não pode consumir}

## Ferramentas Autorizadas

- {lista de ferramentas}

## Skills Obrigatórias

- {skills carregadas automaticamente}

## Critérios de Sucesso

- {lista de critérios}

## Anti-Padrões

- ❌ {comportamentos proibidos}
```

### Fase 7.6 — Geração do AGENTS.md

Gerar ou atualizar o `AGENTS.md` do projeto com:

```markdown
# Agent Topology — {nome-do-projeto}

## Agentes de Governança

| Agente | Papel |
|--------|-------|
| Supervisor | Orquestração, distribuição de tarefas |
| Architecture Review | Qualidade, revisão, validação |
| Context Manager | Documentação, ADRs, topologia |

## Agentes de Domínio

{para cada domínio:}
### {nome-do-agente}
- **Objetivo**: {objetivo}
- **Escopo**: {diret的原}
- **Depende de**: {agentes}
- **Dependido por**: {agentes}
```

### Fase 7.7 — Registro da Nova Skill

1. Salvar skill em: `~/.config/opencode/skills/{agent-name}/SKILL.md`
2. Se aplicável, registrar em `agent-all` como agente de domínio disponível
3. Atualizar `agent-discovery-pipeline` se novo padrão de geração for identificado

## Tools OpenCode

- `write` / `edit` — criar/atualizar skills de agente
- `glob` — verificar skills existentes
- `read` — ler skills existentes para referência
- `bash` — criar diretórios de skills

## Output Esperado

```yaml
generated_agents:
  - agent_id: "agent-dominio-usuarios"
    domain: "Usuários"
    skill_path: "/home/lg/.config/opencode/skills/agent-dominio-usuarios/SKILL.md"
    objective: "Gerencia tudo relacionado a usuários: cadastro, autenticação, perfis"
    scope:
      allowed:
        - "src/services/user/**"
        - "src/controllers/auth*"
      forbidden:
        - "src/services/product/**"
        - "src/services/order/**"
    dependencies:
      - "agent-dominio-compartilhado"
    contracts:
      - "GET /api/users/:id"
      - "POST /api/auth/login"
    skills:
      - "api-patterns"
      - "database"
    success_criteria:
      - "CRUD completo com testes"
      - "Validação de entrada"
      - "Rate limiting em endpoints públicos"

  - agent_id: "agent-dominio-catalogo"
    domain: "Catálogo"
    skill_path: "/home/lg/.config/opencode/skills/agent-dominio-catalogo/SKILL.md"
    ...
```

## Anti-Padrões

- ❌ Gerar agentes com escopo sobreposto
- ❌ Criar agente para shared kernel (não é domínio de negócio)
- ❌ Dividir domínio por tecnologia (ex: "Frontend", "Backend", "Banco")
- ❌ Gerar agentes sem critérios de sucesso
- ❌ Esquecer de registrar a nova skill no ecossistema
- ❌ Assumir skills operacionais sem consultar find-skills primeiro
