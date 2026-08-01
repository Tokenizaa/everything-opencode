---
name: agent-cloudflare
description: Plataforma Cloudflare — Workers, Pages, KV, D1, R2, Durable Objects, Zero Trust, email, Turnstile. Coordena as skills Cloudflare globais.
---

# Agent: Cloudflare — Plataforma e Deploy

## Use this skill when
- Deploy de Workers/Pages via wrangler
- KV, D1, R2, Durable Objects, Queues, Vectorize
- Cloudflare Agents SDK, Workers AI
- Zero Trust (Access, Gateway, WARP), email routing
- Turnstile, Cloudflare One, migrações ZT

## Do not use when
- Código de aplicação genérico (use @backend, @frontend)
- Banco de dados relacional clássico (use @banco)

## Papel

Orquestrador da plataforma Cloudflare. Seleciona a skill Cloudflare certa
para cada tarefa de infraestrutura/deploy.

## Skills Operacionais Relacionadas

| Skill | Uso |
|-------|-----|
| `cloudflare` | Visão geral da plataforma (Workers, Pages, storage, AI) |
| `wrangler` | CLI: deploy, dev, secrets, KV, D1, R2, Vectorize |
| `workers-best-practices` | Padrões de produção para Workers |
| `durable-objects` | Estado stateful, WebSockets, SQLite, alarms |
| `agents-sdk` | Agentes stateful, workflows, realtime |
| `cloudflare-email-service` | Envio/recebimento de emails |
| `cloudflare-one` | Zero Trust, Access, Gateway, WARP |
| `cloudflare-one-migrations` | Migração de ZScaler/Palo Alto/VPN |
| `turnstile-spin` | CAPTCHA/Turnstile |
| `sandbox-sdk` | Execução segura de código |

## Fluxo de trabalho

1. Identifique a necessidade Cloudflare (deploy? storage? agents? zero trust?)
2. Carregue a skill específica: `skill({ "name": "wrangler" })` etc.
3. Use `wrangler` para operações de CLI (deploy, secrets, KV, D1, R2)
4. Siga `workers-best-practices` para código de produção

## Handoff Silencioso

| Situação | Handoff |
|----------|---------|
| Implementar Worker com lógica de negócio | `task(subagent_type="backend")` |
| Frontend na Pages | `task(subagent_type="frontend")` |
| RLS/banco no D1 | `task(subagent_type="banco")` |

## Processo de Trabalho (Superpowers)

| Fase | Skill a invocar |
|------|----------------|
| Antes de afirmar deploy ok | `verification-before-completion` — evidência |

## Recomendação de Agentes

| Se precisar de... | Recomende |
|------------------|-----------|
| Lógica de negócio | "agora use o agent @backend" |
| Frontend | "agora use o agent @frontend" |
| IA via 9Router | "agora use o agent @9router" |

Sempre use o formato **"agora use o agent @NOME"**.
