---
name: knowledge-search
description: Busca semântica/híbrida na base de conhecimento. Busca vetorial (pgvector), híbrida (vetorial + BM25), com filtros por domínio, tabela, threshold. Use para busca semântica pura.
---

# Knowledge Search — Busca Semântica/Híbrida

## Use this skill when
- Busca semântica pura no banco vetorial
- Busca híbrida (vetorial + BM25/keyword)
- Filtros por domínio, tabela, threshold
- Busca por similaridade sem geração de resposta

## Do not use when
- Precisa de geração de resposta/RAG completo (use rag-pipeline)
- Precisa sincronizar dados (use knowledge-sync)
- Operações CRUD diretas (use knowledge-dal)

## Papel

Busca especializada na base vetorial:
1. **Busca Vetorial** — pgvector HNSW, similaridade cosseno
2. **Busca Híbrida** — Vetorial + BM25/keyword (RRF/weighted merge)
3. **Filtros** — domínio, tabela fonte, threshold, topK

## Configuração

```env
# Mesmo provider do rag-pipeline
EMBEDDING_PROVIDER=openai|nvidia|openrouter|local
```

## Endpoint

`POST /v1/search`

## Entrada

| Campo | Obrigatório | Notas |
|---|---|---|
| `model` (ou `provider`) | sim | e.g., `tavily`, `brave`, `searxng`, `exa`, `search-combo` |
| `query` | sim | Query de busca |
| `max_results` | não | Default 5 (até 20-50) |
| `search_type` | não | `web` (default) / `news` |
| `country`, `language` | não | Provider-dependent |
| `time_range` | não | `day`, `week`, `month`, `year` |
| `domain_filter` | não | Include/exclude domains |

## Exemplos

### Tavily (1000/mo free)
```bash
curl -X POST $NINEROUTER_URL/v1/search \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"tavily","query":"9Router open source","max_results":5}'
```

### Exa (Semantic search, 1000/mo)
```bash
curl -X POST $NINEROUTER_URL/v1/search \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -d '{"model":"exa","query":"NVIDIA FastPitch TTS","max_results":10}'
```

### SearXNG (Self-hosted, Free)
```bash
curl -X POST $NINEROUTER_URL/v1/search \
  -d '{"model":"searxng","query":"NVIDIA FastPitch TTS","max_results":10}'
```

### Combo (Auto-fallback)
```bash
curl -X POST $NINEROUTER_URL/v1/search \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -d '{"model":"search-combo","query":"NVIDIA FastPitch TTS","max_results":10}'
```

---

## JS Example

```js
const r = await fetch(`${process.env.NINEROUTER_URL}/v1/search`, {
  method: "POST",
  headers: { "Authorization": `Bearer ${process.env.NINEROUTER_KEY}`, "Content-Type": "application/json" },
  body: JSON.stringify({ model: "search-combo", query: "NVIDIA FastPitch TTS", max_results: 10 }),
});
const { results } = await r.json();
results.forEach(r => console.log(r.title, r.url, r.snippet));
```

---

## Provider Quirks

| Provider | `max_results` | Special Params |
|---|---|---|
| Tavily | 20 | `search_depth`, `domain_filter`, `news` |
| Exa | 20 | `type: neural/keyword`, `category` |
| Brave | 20 | `country`, `language`, `safe_search` |
| Serper | 20 | `country`, `language`, `news` |
| SearXNG | 50 | `language`, `time_range`, `safesearch` |
| Perplexity | 10 | Returns AI `answer` + sources |
| Linkup | 20 | `depth: fast/standard/deep` |
| Google PSE | 10 | **Requires `cx`** (Custom Search Engine ID) |

---

## Quick Selection

| Need | Free Provider |
|---|---|
| **General web search** | `tavily` (1000/mo) or `brave` (2000/mo) |
| **Semantic/Deep Research** | `exa` (1000/mo) |
| **Privacy/No auth** | `searxng` (self-hosted) |
| **AI answer + sources** | `perplexity` (free tier) |
| **Deep research** | `linkup` (free tier) |
| **No API Key** | `searxng` (self-hosted) |

---

## JS Multi-Provider

```js
async function search(query, provider = "search-combo", max = 10) {
  const r = await fetch(`${process.env.NINEROUTER_URL}/v1/search`, {
    method: "POST",
    headers: { "Authorization": `Bearer ${process.env.NINEROUTER_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({ model: provider, query, max_results: max }),
  });
  return (await r.json()).results;
}

// Free providers
await search("NVIDIA FastPitch TTS", "tavily");
await search("NVIDIA FastPitch TTS", "brave");
await search("NVIDIA FastPitch TTS", "exa");
await search("NVIDIA FastPitch TTS", "search-combo"); // Auto-fallback
```

---

## Anti-Patterns (Avoid Paid)

| ❌ Paid | Why |
|---|---|
| Google Custom Search (beyond 100/day) | Requires billing |
| SerpAPI / ScraperAPI / ScrapingBee | Paid credits |
| Bright Data / Bright Data SERP | Enterprise |
| Serper (beyond free) | Paid plans |
| Custom search APIs | Paid |
EOF