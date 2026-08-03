---
name: 9router-web-fetch
description: Fetch URL → markdown/text/HTML via 9Router using FREE providers: Jina Reader, Tavily Extract, Firecrawl (free tier), Exa Contents. Use for scraping, article extraction, URL to markdown.
---

# 9Router — Free Web Fetch (9router Combo)

Requires `NINEROUTER_URL` (+ `NINEROUTER_KEY` if auth). See `9router/SKILL.md`.

## Free Fetch Providers on 9router

| Provider | Model ID | Free Tier | Best For |
|---|---|---|---|
| **Jina Reader** | `jina-reader/fetch` | **Free (1M chars/mo)** | Fast, clean markdown, no auth |
| **Tavily Extract** | `tavily/fetch` | 1000 req/mo | Bulk extract, raw content |
| **Firecrawl** | `firecrawl/fetch` | 500 pages/mo | JS-rendered, authenticated |
| **Exa Contents** | `exa/fetch` | 1000 req/mo | Pre-indexed, fast text |
| **Tavily** | `tavily/fetch` | 1000 req/mo | Bulk extract |

---

## Discover

```bash
curl "$NINEROUTER_URL/v1/models/web" | jq '.data[] | select(.kind=="webFetch") | {id, owned_by}'
```

---

## Endpoint

`POST $NINEROUTER_URL/v1/web/fetch`

| Field | Required | Notes |
|---|---|---|
| `model` / `provider` | yes | e.g., `jina-reader`, `tavily`, `firecrawl`, `exa` |
| `url` | yes | URL to extract |
| `format` | no | `markdown` (default) / `text` / `html` |
| `max_characters` | no | Truncate output |

---

## Examples

### Jina Reader (Free 1M chars/mo, No Auth)
```bash
curl -X POST "$NINEROUTER_URL/v1/web/fetch" \
  -H "Content-Type: application/json" \
  -d '{"model":"jina-reader","url":"https://example.com/article","format":"markdown"}'
```

### Firecrawl (JS-rendered, 500 pages/mo)
```bash
curl -X POST "$NINEROUTER_URL/v1/web/fetch" \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"firecrawl","url":"https://example.com/js-page","format":"markdown"}'
```

### Exa Contents (Pre-indexed, Fast)
```bash
curl -X POST "$NINEROUTER_URL/v1/web/fetch" \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -d '{"model":"exa","url":"https://example.com","format":"markdown"}'
```

### Tavily Extract (Bulk, 1000/mo)
```bash
curl -X POST "$NINEROUTER_URL/v1/web/fetch" \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -d '{"model":"tavily","url":"https://example.com","format":"markdown"}'
```

### Combo (Auto-fallback)
```bash
curl -X POST "$NINEROUTER_URL/v1/web/fetch" \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -d '{"model":"fetch-combo","url":"https://example.com","format":"markdown"}'
```

---

## JS Example

```js
const r = await fetch(`${process.env.NINEROUTER_URL}/v1/web/fetch`, {
  method: "POST",
  headers: { "Authorization": `Bearer ${process.env.NINEROUTER_KEY}`, "Content-Type": "application/json" },
  body: JSON.stringify({ model: "fetch-combo", url: "https://example.com", format: "markdown", max_characters: 5000 }),
});
const { data } = await r.json();
console.log(data.title, data.content.length);
```

---

## Response Shape

```json
{
  "provider": "jina-reader",
  "url": "https://...",
  "title": "Article Title",
  "content": { "format": "markdown", "text": "...", "length": 12345 },
  "metadata": { "author": null, "published_at": null, "language": "en" }
}
```

---

## Provider Comparison (Free)

| Provider | Free Limit | Auth | JS Render | Best For |
|---|---|---|---|---|
| **Jina Reader** | 1M chars/mo | Optional | ❌ | Fast, clean markdown |
| **Firecrawl** | 500 pages/mo | Required | ✅ | JS-heavy, auth pages |
| **Exa** | 1000 req/mo | Required | ❌ | Pre-indexed, instant |
| **Tavily** | 1000 req/mo | Required | ❌ | Bulk, raw content |

---

## Anti-Patterns (Avoid Paid)

| ❌ Paid | Why |
|---|---|
| Apify | Paid credits |
| Bright Data | Enterprise |
| ScrapingBee | Paid credits |
| ScraperAPI | Paid credits |
| Custom headless Chrome | GPU/server costs |

---

## Quick Selection

| Need | Free Provider |
|---|---|
| Clean markdown, no auth | Jina Reader (1M chars/mo) |
| JS-rendered pages | Firecrawl (500/mo) |
| Instant pre-indexed | Exa (1000/mo) |
| Bulk extraction | Tavily (1000/mo) |
| Auto-fallback | fetch-combo |

---

## Anti-Patterns

- ❌ Using paid scrapers (Apify, Bright Data)
- ❌ Running headless Chrome yourself (GPU/server costs)
- ❌ Not checking rate limits
- ❌ Scraping without `robots.txt` check
