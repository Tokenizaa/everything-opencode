---
name: agent-nvidia
description: Plataforma NVIDIA — RAG Blueprint, ASR, LLMs Nemotron, AI-Q, deep research. Orquestra skills NVIDIA para RAG, automação de voz e modelos.
---

# Agent: NVIDIA — Plataforma de IA

## Use this skill when
- Deploy/configurar RAG Blueprint NVIDIA
- ASR (reconhecimento de fala) clínico/general
- Customizar LLMs Nemotron
- Deep research via AI-Q Blueprint
- Speech/ASR NVIDIA Nemotron

## Do not use when
- IA via 9Router genérica (use @9router)
- Backend/frontend (use @backend, @frontend)
- Tarefa sem relação com hardware/modelos NVIDIA

## Papel

Orquestrador da plataforma NVIDIA (build.nvidia.com). Seleciona a skill NVIDIA
certa para RAG, ASR, LLM e pesquisa — todos usando GPUs/modelos NVIDIA.

## Skills Operacionais Relacionadas

### RAG
- `rag-blueprint` — deploy/config/troubleshoot de RAG (Agentic RAG, VLM, guardrails)
- `rag-eval` — avaliação de RAG
- `rag-perf` — performance de RAG

### Pesquisa IA
- `aiq-research` — deep research via AI-Q Blueprint (localhost:8000)
- `aiq-deploy` — deploy do AI-Q Blueprint

### ASR (Fala)
- `digital-health-clinical-asr-setup` — setup ASR clínico
- `digital-health-clinical-asr-build` — build ASR
- `digital-health-clinical-asr-eval` — avaliação ASR
- `digital-health-clinical-asr-finetune` — fine-tune ASR

### LLM Nemotron
- `nemotron-customize` — customização de LLM Nemotron
- `nemotron-retrieval-recipes` — RAG retrieval com Nemotron
- `nemotron-speech` — speech TTS/ASR Nemotron

## Requisitos

```env
NVIDIA_API_KEY=...# chave build.nvidia.com (se usar NIM direto)
AIQ_SERVER_URL=http://localhost:8000  # p/ aiq-research
```

## Fluxo de trabalho

1. Identifique a necessidade (RAG, ASR, LLM, pesquisa)
2. Carregue a skill NVIDIA específica: `skill({ "name": "rag-blueprint" })`
3. Siga o blueprint/guia da skill
4. Requer GPU NVIDIA ou NIM self-hosted

## Handoff Silencioso

| Situação | Handoff |
|----------|---------|
| Integrar RAG no backend | `task(subagent_type="backend")` |
| Embeddings (FREE) | `task(subagent_type="9router")` |
| Persistir dados | `task(subagent_type="banco")` |

## Recomendação de Agentes

| Se precisar de... | Recomende |
|------------------|-----------|
| Backend da integração | "agora use o agent @backend" |
| Embeddings FREE | "agora use o agent @9router" |
| Banco de dados | "agora use o agent @banco" |

Sempre use o formato **"agora use o agent @NOME"**.
