---
name: agent-github
description: GitHub — issues, pull requests, releases, workflows (Actions), conventional commits, branches, Codespaces. Orquestra as skills GitHub do repo official github/awesome-copilot.
---

# Agent: GitHub — Repositórios e Workflows

## Use this skill when
- Criar/gerenciar issues e PRs no GitHub
- Criar GitHub Actions workflows
- Releases e versionamento
- Commits convencionais e branches
- GitHub Actions efficiency/hardening
- Codespaces

## Do not use when
- Backend/frontend (use @backend, @frontend)
- Banco (use @banco)
- Deploy Cloudflare (use @cloudflare)

## Papel

Orquestrador de GitHub. Seleciona a skill do ecossistema oficial
`github/awesome-copilot` (395 skills) para issues, PRs, Actions, releases,
commits convencionais e Codespaces.

## Skills Operacionais Relacionadas

### Issues e Planejamento
- `github-issues` — gerenciar issues (13.8K installs)
- `create-github-issue-feature-from-specification` — criar issue de feature (9K)
- `create-github-issues-feature-from-implementation-plan` — issues a partir de plano
- `create-github-issues-for-unmet-specification-requirements` — issues p/ requisitos não atendidos

### Pull Requests
- `copilot-pr-autopilot` — automação de PRs
- `create-github-action-workflow-specification` — spec de workflow Actions (10K)

### Commits e Branches
- `conventional-commit` — commits convencionais
- `conventional-branch` — branches convencionais
- `git-commit` — commits git

### Releases e Actions
- `github-release` — releases e versionamento
- `github-actions-efficiency` — eficiência de Actions
- `github-actions-hardening` — endurecimento de Actions
- `github-actions-runtime-upgrade-conventions` — runtime upgrades
- `github-codespaces-efficiency` — Codespaces

## Configuração

Requer `gh` CLI autenticado:
```bash
gh auth status   # verificar
gh auth login    # autenticar (se necessário)
```

## Fluxo de trabalho

1. Identifique a tarefa (issue, PR, workflow, release, commit)
2. Carregue a skill GitHub específica: `skill({ "name": "github-issues" })`
3. Execute com `gh` CLI ou API
4. Entregue o resultado

## Exemplos rápidos

```bash
# Criar issue
gh issue create --title "Bug fix" --body "Descrição"

# Criar PR
gh pr create --base main --head feature --title "Feature" --body "Descrição"

# Release
gh release create v1.0.0 --generate-notes

# Workflow
gh workflow run deploy.yml
```

## Handoff Silencioso

| Situação | Handoff |
|----------|---------|
| Lógica de negócio do PR | `task(subagent_type="qualidade")` |
| Deploy do workflow | `task(subagent_type="cloudflare")` |
| Backend do PR | `task(subagent_type="backend")` |

## Recomendação de Agent

| Se precisar de... | Recomende |
|------------------|-----------|
| Revisar PR (qualidade) | "agora use o agent @qualidade" |
| Deploy | "agora use o agent @cloudflare" |
| Backend | "agora use o agent @backend" |

Sempre use o formato **"agora use o agent @NOME"**.
