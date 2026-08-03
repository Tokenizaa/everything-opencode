---
name: 9router-embeddings
description: Vector embeddings via 9Router using FREE providers: NVIDIA, Gemini, Mistral, Voyage, Nvidia, GitHub, OpenRouter, HF. Use for RAG, semantic search, similarity, clustering. Models from /v1/models/embedding.
---

# 9Router — Free Embeddings (NVIDIA + Free Tier)

Requires `NINEROUTER_URL` (+ `NINEROUTER_KEY`). See `9router/SKILL.md`.

## Free Embedding Models on 9router

### NVIDIA (Free)
| Model ID | Dimensions | Description |
|---|---|---|
| `nvidia/nv-embed-v2` | 1024 | NVIDIA NV-Embed v2 (state-of-the-art) |
| `nvidia/nv-embed-qa` | 1024 | NVIDIA QA-optimized embeddings |

### Free Tier Providers

| Provider | Models | Free Limit | Dimensions | Best For |
|---|---|---|---|---|
| **NVIDIA** | `nvidia/nv-embed-v2`, `nvidia/nv-embed-qa` | **Free** | 1024 | SOTA embeddings |
| **Gemini** | `gemini/text-embedding-004` | Free tier | 768 | Multilingual |
| **Mistral** | `mistral/mistral-embed` | Free tier | 1024 | Multilingual |
| **Voyage AI** | `voyage/voyage-3`, `voyage/voyage-3-large` | Free tier | 1024/2048 | Code, RAG |
| **GitHub** | `github/github-embed` | Free | 768 | Code embeddings |
| **OpenRouter** | Proxy to Voyage/Mistral/Gemini | Free tier | Varies | Proxy |
| **Hugging Face** | `huggingface/sentence-transformers/all-MiniLM-L6-v2` | Free tier | 384 | Fast, small |
| **NVIDIA** | `nvidia/nv-embed-v2` | **Free** | 1024 | SOTA |

---

## Discover

```bash
curl "$NINEROUTER_URL/v1/models/embedding" | jq '.data[] | select(.owned_by=="nvidia" or .owned_by=="gemini" or .owned_by=="mistral" or .owned_by=="voyage-ai" or .owned_by=="github" or .owned_by=="openrouter" or .owned_by=="huggingface") | {id, owned_by}'
```

---

## Endpoint

`POST $NINEROUTER_URL/v1/embeddings`

| Field | Required | Notes |
|---|---|---|
| `model` | yes | from `/v1/models/embedding` |
| `input` | yes | string or string[] |
| `encoding_format` | no | `float` (default) / `base64` |
| `dimensions` | no | OpenAI v3 only (`text-embedding-3-*`) |

---

## Examples

### NVIDIA NV-Embed v2 (Free, SOTA)
```bash
curl -X POST $NINEROUTER_URL/v1/embeddings \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"nvidia/nv-embed-v2","input":["Hello world","RAG chunk text"]}'
```

### Gemini (Free Tier)
```bash
curl -X POST $NINEROUTER_URL/v1/embeddings \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"gemini/text-embedding-004","input":["Chào bạn","Vector search"]}'
```

### Mistral (Free Tier)
```bash
curl -X POST $NINEROUTER_URL/v1/embeddings \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"mistral/mistral-embed","input":["RAG document","Query text"]}'
```

### Batch Input (Faster)
```bash
curl -X POST $NINEROUTER_URL/v1/embeddings \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"nvidia/nv-embed-v2","input":["chunk 1","chunk 2","chunk 3","chunk 4"]}'
```

---

## JS Example

```js
const r = await fetch(`${process.env.NINEROUTER_URL}/v1/embeddings`, {
  method: "POST",
  headers: { "Authorization": `Bearer ${process.env.NINEROUTER_KEY}`, "Content-Type": "application/json" },
  body: JSON.stringify({ model: "nvidia/nv-embed-v2", input: "RAG chunk text" }),
});
const { data } = await r.json();
console.log(data[0].embedding.length); // 1024
```

---

## Response

```json
{
  "object": "list",
  "model": "nvidia/nv-embed-v2",
  "data": [
    { "object": "embedding", "index": 0, "embedding": [0.0123, -0.0456, ...] }
  ],
  "usage": { "prompt_tokens": 5, "total_tokens": 5 }
}
```

---

## RAG Pipeline (Free)

```js
async function embedChunks(chunks, model = "nvidia/nv-embed-v2") {
  const r = await fetch(`${process.env.NINEROUTER_URL}/v1/embeddings`, {
    method: "POST",
    headers: { "Authorization": `Bearer ${process.env.NINEROUTER_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({ model, input: chunks, encoding_format: "float" }),
  });
  const { data } = await r.json();
  return data.map(d => d.embedding);
}

// Usage
const vectors = await embedChunks(["chunk 1", "chunk 2", "chunk 3"], "nvidia/nv-embed-v2");
// Store in vector DB (Chroma, Qdrant, Pinecone free tier, pgvector)
```

---

## Provider Comparison (Free)

| Provider | Model | Dim | Free Limit | Best For |
|---|---|---|---|---|
| **NVIDIA** | `nv-embed-v2` | 1024 | **Free** | SOTA general |
| **NVIDIA** | `nv-embed-qa` | 1024 | **Free** | QA-optimized |
| **Gemini** | `text-embedding-004` | 768 | Free tier | Multilingual |
| **Mistral** | `mistral-embed` | 1024 | Free tier | General |
| **Voyage AI** | `voyage-3` | 1024 | Free tier | Code, RAG |
| **GitHub** | `github-embed` | 768 | Free | Code |
| **OpenRouter** | Proxy | Varies | Free tier | Access all |
| **HF** | `all-MiniLM-L6-v2` | 384 | Free tier | Fast, small |

---

## RAG Pipeline (Completely Free)

```js
// 1. Embed with NVIDIA (free, SOTA)
const vectors = await embedChunks(chunks, "nvidia/nv-embed-v2");

// 2. Store in free vector DB
// - Chroma (local, free)
// - Qdrant (local, free)
// - pgvector (Postgres, free)
// - Pinecone (free tier)
// - Weaviate (free tier)

// 3. Search
const queryVec = await embedQuery(query, "nvidia/nv-embed-v2");
const results = await vectorDB.query(queryVec, topK: 5);
```

---

## Batch Best Practices

- **Batch size**: 100-1000 chunks per request (provider limits vary)
- **Use `nvidia/nv-embed-v2`** for highest quality (free)
- **Use `nvidia/nv-embed-qa`** for QA-specific retrieval
- **Normalize vectors** before storing (cosine similarity)
- **Cache embeddings** to avoid re-computation

---

## Anti-Patterns (Avoid Paid)

| ❌ Paid | Why |
|---|---|
| OpenAI `text-embedding-3-large` | Requires paid key |
| Pinecone (beyond free tier) | $70+/mo |
| Weaviate Cloud (beyond free) | Paid |
| Qdrant Cloud (beyond free) | Paid |
| Pinecone Serverless | $0.50/1M vectors |
| Cohere Embed | Paid |
| Voyage AI (beyond free) | Paid |

---

## Quick Selection

| Need | Free Model |
|---|---|
| **Best quality (free)** | `nvidia/nv-embed-v2` |
| **QA / RAG** | `nvidia/nv-embed-qa` |
| **Multilingual** | `gemini/text-embedding-004` |
| **Code search** | `github/github-embed` |
| **Fast + small** | `huggingface/all-MiniLM-L6-v2` |
| **Code RAG** | `voyage/voyage-3` |
