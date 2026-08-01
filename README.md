# 🚀 opencode-agents

**33 agents + 69 skills prontos para o OpenCode** — arquitetura completa de agentes de IA para desenvolvimento, com discovery pipeline, simbiose com superpowers e design systems.

## ⚡ Instalação

```bash
# 1. Clone
git clone https://github.com/<SEU_USER>/opencode-agents.git
cd opencode-agents

# 2. Instale (agents + skills + config)
bash install.sh

# 3. Opcional: biblioteca de design (153 marcas, 81MB)
bash install.sh --design
```

## 📦 O que instala

| Componente | Qtd | Descrição |
|---|---|---|
| **Agents** | 33 | Governança, backend, banco, frontend, testes, segurança, marketing, cloudflare, 9router, design |
| **Skills** | 69 | Agent-* (18) + operacionais (51): padrões, TDD, design, docs |
| **AGENTS.md** | 1 | Topologia completa |
| **Design** | opcional | 153 design-systems + 115 templates (Open Design) |

## 🧩 Agentes

### Governança
`@supervisor` · `@qualidade` · `@documentacao` · `@descoberta`

### Técnicos por camada
`@backend` (+routes/services/auth/middleware/validation) · `@banco` (+schema/queries/migrations/indexing) · `@frontend` (+components/state/routing/styling) · `@testes` (+unit/integracao/e2e/performance)

### Especializados
`@seguranca` · `@build-error-resolver` · `@refactor-cleaner`

### Orquestradores
`@marketing` (47 skills) · `@cloudflare` (10 skills) · `@9router` (8 skills) · `@design` (9 skills + biblioteca)

## 🎯 Comandos úteis

```
@qualquer-agente "qual sua função"   → agente carrega skill e se apresenta
@supervisor "executar discovery"     → pipeline de 10 fases
@descoberta "descobrir domínios"     → gera agentes de domínio do projeto
```

## 🔧 Requisitos

- [OpenCode](https://opencode.ai) instalado
- (opcional) 9Router local em `http://localhost:20128` para IA
- (opcional) Plugin superpowers: `superpowers@git+https://github.com/obra/superpowers.git`

## 📚 Fontes integradas

everything-claude-code · open-design · obra/superpowers · anthropics/skills · vercel-labs · stripe/ai · andrej-karpathy-skills

## 📄 Licença

MIT
