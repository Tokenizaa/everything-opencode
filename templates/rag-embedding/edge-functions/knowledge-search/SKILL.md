---
name: knowledge-search
description: Edge Function — Busca semântica/híbrida na base de conhecimento via pgvector. Busca vetorial, híbrida (vetorial + BM25), com filtros.
---

# Knowledge Search — Edge Function

## Configuração

```env
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=xxx
NINEROUTER_URL=http://localhost:20128
NINEROUTER_KEY=sk-...
```

## Endpoint

`POST /v1/search`

## Entrada

| Campo | Obrigatório | Notas |
|---|---|---|
| `model` / `provider` | sim | e.g., `tavily`, `brave`, `searxng`, `exa`, `search-combo` |
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

### Auto-fallback Combo
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
  body: JSON.stringify({ model: "search-combo", query: "free TTS NVIDIA", max_results: 10 }),
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
| Perplexity | 10 | Returns AI `answer` + sources |
| Linkup | 20 | `depth: fast/standard/deep` |
| Google PSE | 10 | **Requires `cx`** (Custom Search Engine ID) |

---

## Provider Comparison (Free)

| Provider | Free Limit | Best For |
|---|---|---|
| **Tavily** | 1000/mo | General web, news, fact-check |
| **Brave** | 2000/mo | Privacy, news, safe search |
| **Exa** | 1000/mo | High-quality, neural search |
| **SearXNG** | Unlimited (self-host) | Privacy, meta-search |
| **Perplexity** | Free tier | AI answer + sources |
| **Linkup** | Free tier | Deep research |
| **Google PSE** | 100/day | Custom search engine |

---

## Anti-Patterns (Avoid Paid)

| ❌ Paid | Why |
|---|---|
| Google Custom Search (beyond 100/day) | Requires billing |
| SerpAPI / ScraperAPI / ScrapingBee | Paid credits |
| Bright Data / Bright Data SERP | Enterprise |
| Serper (beyond free) | Paid plans |
| Custom search APIs | Paid |

---

## Quick Selection

| Need | Free Provider |
|---|---|
| **General web search** | `tavily` (1000/mo) or `brave` (2000/mo) |
| **Privacy / No auth** | `searxng` (self-host) |
| **AI answer + sources** | `perplexity` (free tier) |
| **Deep research** | `linkup` (free tier) |
| **No API Key** | `searxng` (self-hosted) |
SKILLEOF