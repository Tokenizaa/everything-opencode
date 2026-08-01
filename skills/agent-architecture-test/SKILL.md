---
name: agent-architecture-test
description: Teste HARD da arquitetura de agents — valida manifest, agents, skills, handoff, simbiose, performance e erros. Gera relatório final estruturado. Use quando o usuário pedir "teste hard", "auditoria da arquitetura", "teste da estrutura" ou "health check dos agents".
---

# Teste HARD da Arquitetura de Agents

Auditoria completa e executável da estrutura de agents do OpenCode.
Valida o manifesto, os agents, as skills, o handoff silencioso, a simbiose
(superpowers + Karpathy) e gera um relatório de performance e erros.

## Quando usar

- Usuário pede "teste hard", "teste da estrutura", "auditoria da arquitetura"
- Antes de um projeto crítico
- Após grandes mudanças na configuração de agents
- Health check periódico do sistema

## Parte 1 — Auditoria Estrutural (antes de qualquer código)

### 1.1 Manifest Global
- Ler `~/.opencode/AGENTS.md` → confirmar agents listados
- Verificar `CLAUDE.md` symlink → `AGENTS.md`
- Reportar: nº agents no manifest / nº no config

### 1.2 AGENTS.md do Projeto
- Ler AGENTS.md local (se existir)
- Confirmar que complementa o global (não substitui)

### 1.3 Configuração
- `~/.config/opencode/opencode.jsonc`: agents registrados, MCPs, plugin superpowers
- Listar mode=all vs mode=subagent

### 1.4 Skills
- Para cada agent no config: a skill `agent-*` existe?
- Skills órfãs / referências quebradas / sem frontmatter

### 1.5 Comando "qual sua função"
- Invocar 3 agents aleatórios → verificar skill correta + resposta estruturada

## Parte 2 — Fluxo Real (handoff silencioso + simbiose)

Selecionar UMA feature cross-layer do projeto (ou criar uma de teste) e executar
o pipeline completo com cronometragem:

| Fase | Agente | Entrega |
|------|--------|---------|
| T0 | supervisor | contexto + plano (brainstorming/writing-plans) |
| T1 | banco | schema + migration (TDD) |
| T2 | backend | endpoints (TDD) |
| T3 | frontend | UI (TDD onde aplicar) |
| T4 | testes | suíte + verificação |
| T5 | qualidade | review arquitetura |
| T6 | seguranca | auditoria |
| T7 | supervisor | validação final + relatório |

**Regras:**
- Cronometrar cada fase (início/fim)
- A cada handoff: próximo agente DEVE carregar skill (verificar!)
- Se agent recomendar outro ("agora use o agent @X") → acionar via task tool
- Registrar TODOS os erros (não esconder)

## Parte 3 — Relatório Final Obrigatório

```markdown
## 📊 RELATÓRIO DE TESTE HARD — <PROJETO>

### 1. Resumo Executivo
- Data/hora, projeto, feature testada
- VEREDITO: ✅ PASS / ⚠️ PARCIAL / ❌ FAIL

### 2. Métricas de Performance (por fase)
| Fase | Agente | Skill? | Tempo | Erros | Resultado |
|------|--------|--------|-------|-------|-----------|
- Tempo total / fase mais rápida / mais lenta

### 3. Auditoria Estrutural
- Agents manifest vs config / skills totais / órfãs / quebradas
- MCPs, plugin, symlinks / comando "qual sua função"

### 4. Erros e Warnings
| Severidade | Fase | Descrição | Correção |

### 5. Arquivos Criados/Modificados

### 6. Evidências (testes rodando, build, migrations)

### 7. Health Check (0-100)
- manifest(20) agents(20) skills(20) handoff(20) simbiose(20)

### 8. Recomendações (top 3)
```

## Regras Absolutas

- NUNCA afirmar "pronto" sem evidência (verification-before-completion)
- NUNCA pular fase do pipeline
- Registrar QUALQUER falha no relatório (transparência total)
- O relatório é o entregável PRINCIPAL

## Handoff

| Situação | Handoff |
|----------|---------|
| Precisa executar discovery | `task(subagent_type="descoberta")` |
| Precisa implementar | `task(subagent_type="backend")` ou agent da camada |
| Precisa de banco | `task(subagent_type="banco")` |
| Precisa de qualidade | `task(subagent_type="qualidade")` |

## Recomendação de Agentes

| Se precisar de... | Recomende |
|------------------|-----------|
| Implementar | "agora use o agent @backend" |
| Banco | "agora use o agent @banco" |
| Orquestrar | "agora use o agent @supervisor" |

Sempre use o formato **"agora use o agent @NOME"**.
