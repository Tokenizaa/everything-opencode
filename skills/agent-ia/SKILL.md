---
name: agent-ia
description: Acesso a IA via 9Router — chat, imagem, TTS, STT, embeddings, web search, web fetch. Usa apenas providers FREE (NVIDIA + 9router combo). Use para gerar conteúdo, transcrever, sintetizar voz, buscar na web.
---

# Agent: IA — Capacidades 9Router (FREE)

## Use this skill when
- Gerar texto/código com LLM (chat)
- Gerar imagens (DALL-E, Gemini, FLUX)
- Texto para fala (TTS — NVIDIA FastPitch, Edge TTS)
- Fala para texto (STT — Whisper, Groq)
- Embeddings / RAG / busca semântica
- Busca na web (Tavily, Brave, Exa)
- Extrair conteúdo de URL (Jina, Firecrawl)

## Do not use when
- Tarefa de desenvolvimento puro (use @backend, @frontend, @banco)
- Revisão de código (use @qualidade)

## Papel

Gateway de capacidades de IA via 9Router, usando **apenas providers FREE**
(NVIDIA + 9router combo com auto-fallback). Zero custo, zero boilerplate.

## Skills Operacionais Relacionadas

Carregue a skill específica conforme a necessidade:

| Capacidade | Skill | Provider FREE |
|-----------|-------|---------------|
| Chat / código | `9router-chat` | combo auto-fallback |
| Imagem | `9router-image` | Gemini, FLUX, DALL-E |
| TTS (texto→fala) | `9router-tts` | NVIDIA FastPitch, Tacotron2, Edge TTS |
| STT (fala→texto) | `9router-stt` | NVIDIA Parakeet, Groq Whisper, Gemini |
| Embeddings | `9router-embeddings` | NVIDIA NV-Embed-v2, Gemini |
| Web search | `9router-web-search` | Tavily, Brave, Exa, SearXNG |
| Web fetch | `9router-web-fetch` | Jina Reader, Firecrawl, Exa |

## Configuração

```bash
export NINEROUTER_URL="http://localhost:20128"
export NINEROUTER_KEY="sk-..."   # se auth habilitada
```

Verificar: `curl $NINEROUTER_URL/api/health` → `{"ok":true}`

## Anti-Padrões

- ❌ Usar providers pagos (OpenAI key, ElevenLabs, Deepgram pago)
- ❌ Ignorar limites de free tier (Tavily 1000/mo, Firecrawl 500/mo)
- ❌ Duplicar chamadas HTTP (usar as 9router skills como referência)

## Processo de Trabalho (Superpowers)

| Fase | Skill a invocar |
|------|----------------|
| Antes de afirmar resultado | `verification-before-completion` — evidência de resposta obtida |

## Recomendação de Agentes

| Se precisar de... | Recomende |
|------------------|-----------|
| Backend | "agora use o agent @backend" |
| Frontend | "agora use o agent @frontend" |
| Testes | "agora use o agent @testes" |

Sempre use o formato **"agora use o agent @NOME"**.
