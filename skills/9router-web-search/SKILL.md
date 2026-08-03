---
name: 9router-web-search
description: Web search via 9Router using FREE providers: Tavily, Brave, SearXNG, Exa (free tier), You.com, SearchAPI, Perplexity (free tier). Use for web search, fact-checking, research. Model IDs from /v1/models/web (kind: webSearch).
---

# 9Router — Free Web Search (Tavily + 9router Free Tier)

Requires `NINEROUTER_URL` (+ `NINEROUTER_KEY`). See `9router/SKILL.md`.

## Free Search Providers on 9router

### Free Tier / Generous Free Limits

| Provider | Model ID | Free Limit | Features |
|---|---|---|---|
| **Tavily** | `tavily/search` | 1000 searches/mo | General, news, domain filter, depth |
| **Brave Search** | `brave/search` | 2000 queries/mo | Web, news, country/lang, safe search |
| **SearXNG** | `searxng/search` | Self-hosted / Free | No auth, meta-search, privacy |
| **Exa** | `exa/search` | 1000 req/mo | High-quality, domain filter, categories |
| **You.com** | `youcom/search` | Free tier | Web, news, domain filter, time range |
| **SearchAPI** | `searchapi/search` | Free tier | Google/Bing/DuckDuckGo, pagination |
| **Perplexity** | `perplexity/search` | Free tier | AI answers + sources |
| **Linkup** | `linkup/search` | Free tier | Deep research, domain filter |
| **Google PSE** | `google-pse/search` | 100 queries/day | Requires `cx` (Custom Search Engine ID) |

### Combo (Auto-fallback)
- `search-combo` — chains providers with auto-fallback

---

## Discover

```bash
# List free search providers
curl "$NINEROUTER_URL/v1/models/web" | jq '.data[] | select(.kind=="webSearch") | {id, owned_by, kind}'

# Per-provider config
curl "$NINEROUTER_URL/v1/models/info?id=tavily/search"
```

---

## Endpoint

`POST $NINEROUTER_URL/v1/search`

| Field | Required | Notes |
|---|---|---|
| `model` (or `provider`) | yes | e.g., `tavily`, `brave`, `searxng`, `exa`, `search-combo` |
| `query` | yes | Search query string |
| `max_results` | no | Default 5 (up to 20-50) |
| `search_type` | no | `web` (default) / `news` |
| `country`, `language` | no | Provider-dependent |
| `time_range` | no | `day`, `week`, `month`, `year` |
| `domain_filter` | no | Include/exclude domains |
| `depth` | no | `fast`/`standard`/`deep` (Linkup) |

---

## Examples

### Tavily (1000/mo free)
```bash
curl -X POST "$NINEROUTER_URL/v1/search" \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"tavily","query":"9Router open source","max_results":5}'
```

### Brave (2000/mo free)
```bash
curl -X POST "$NINEROUTER_URL/v1/search" \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -d '{"model":"brave","query":"free AI tools 2024","max_results":10}'
```

### SearXNG (Self-hosted / Free)
```bash
curl -X POST "$NINEROUTER_URL/v1/search" \
  -d '{"model":"searxng","query":"privacy respecting search","max_results":10}'
```

### Exa (1000/mo free)
```bash
curl -X POST "$NINEROUTER_URL/v1/search" \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -d '{"model":"exa","query":"latest LLM benchmarks","max_results":5}'
```

### Auto-fallback Combo
```bash
curl -X POST "$NINEROUTER_URL/v1/search" \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -d '{"model":"search-combo","query":"latest NVIDIA TTS models","max_results":10}'
```

---

## JS Example

```js
const r = await fetch(`${process.env.NINEROUTER_URL}/v1/search`, {
  method: "POST",
  headers: { "Authorization": `Bearer ${process.env.NINEROUTER_KEY}`, "Content-Type": "application/json" },
  body: JSON.stringify({ model: "search-combo", query: "free TTS NVIDIA 9router", max_results: 10 }),
});
const data = await r.json();
data.results.forEach(r => console.log(r.title, r.url, r.snippet));
```

---

## Response Shape

```json
{
  "provider": "tavily",
  "query": "free TTS NVIDIA",
  "results": [
    {
      "title": "NVIDIA FastPitch TTS",
      "url": "https://github.com/NVIDIA/FastPitch",
      "snippet": "FastPitch is a NVIDIA TTS model...",
      "score": 0.95,
      "position": 1
    }
  ],
  "answer": null,
  "usage": { "queries_used": 1, "search_cost_usd": 0 },
  "metrics": { "response_time_ms": 850, "upstream_latency_ms": 700 }
}
```

---

## Provider Quirks

| Provider | `max_results` | Special Params |
|---|---|---|
| Tavily | 20 | `search_depth`, `domain_filter`, `news` |
| Brave | 20 | `country`, `language`, `safe_search` |
| Exa | 20 | `type: neural/keyword`, `category` |
| SearXNG | 50 | `language`, `time_range`, `safesearch` |
| Perplexity | 10 | Returns AI `answer` + sources |
| Linkup | 20 | `depth: fast/standard/deep` |
| Google PSE | 10 | **Requires `cx`** (Custom Search Engine ID) |

---

## Free Limits Summary

| Provider | Free Monthly | Best For |
|---|---|---|
| **Tavily** | 1000 searches | General web, news, fact-check |
| **Brave** | 2000 queries | Privacy, news, safe search |
| **Exa** | 1000 req | High-quality, neural search |
| **SearXNG** | Unlimited (self-host) | Privacy, meta-search |
| **Perplexity** | Free tier | AI answer + sources |
| **You.com** | Free tier | AI answer + web |
| **SearchAPI** | Free tier | Google/Bing proxy |
| **Linkup** | Free tier | Deep research |
| **Google PSE** | 100/day | Custom engine |

---

## Quick Selection

| Need | Free Provider |
|---|---|
| **General web search** | `tavily` (1000/mo) or `brave` (2000/mo) |
| **Privacy / No auth** | `searxng` (self-host) |
| **High quality / Neural** | `exa` (1000/mo) |
| **AI answer + sources** | `perplexity` or `youcom` |
| **News** | `tavily` (news search) or `brave` (news) |
| **Auto-fallback** | `search-combo` |

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
