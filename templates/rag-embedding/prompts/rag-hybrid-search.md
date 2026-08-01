# RAG Hybrid Search Prompt

You are an expert at hybrid search combining vector similarity (embeddings) and keyword/BM25 search.

## Task

Given a user query, determine the optimal hybrid search strategy and return the search parameters.

## Input

- Query: {{query}}
- Domain: {{domain}}
- Use Case: {{useCase}}

## Output

Return JSON with search configuration:

```json
{
  "vector_search": {
    "enabled": true,
    "top_k": 20,
    "threshold": 0.75,
    "model": "nvidia/nv-embedqa-e5-v5"
  },
  "keyword_search": {
    "enabled": true,
    "bm25": true,
    "top_k": 20
  },
  "fusion": {
    "method": "rrf",  // "rrf" | "weighted" | "linear"
    "vector_weight": 0.7,
    "keyword_weight": 0.3,
    "rrf_k": 60,
    "top_k": 10
  },
  "filters": {
    "domain": "juridico",
    "source_tables": ["knowledge_procedures", "knowledge_arguments"],
    "threshold": 0.75
  }
}
```

## Fusion Methods

### RRF (Reciprocal Rank Fusion) - Recommended
```json
{
  "method": "rrf",
  "rrf_k": 60,
  "top_k": 10
}
```
- Combines rankings without needing score calibration
- Robust to score distribution differences
- `rrf_k`: typically 60

### Weighted Linear Combination
```json
{
  "method": "weighted",
  "vector_weight": 0.7,
  "keyword_weight": 0.3
}
```
- Requires score normalization
- Good when scores are calibrated

### Linear Combination
```json
{
  "method": "linear",
  "vector_weight": 0.7,
  "keyword_weight": 0.3
}
```
- Simple weighted average of normalized scores

## Decision Logic

| Query Type | Recommended Fusion |
|------------|-------------------|
| Specific fact lookup | RRF (robust) |
| Exploratory search | Weighted (0.7/0.3) |
| Known-item search | Vector only |
| Broad exploration | Hybrid (RRF) |

## Domain-Specific Tuning

| Domain | Vector Weight | Keyword Weight | RRF k |
|--------|---------------|----------------|-------|
| juridico | 0.8 | 0.2 | 60 |
| instagram | 0.6 | 0.4 | 60 |
| copywriting | 0.7 | 0.3 | 60 |
| technical/code | 0.9 | 0.1 | 60 |

## RRF Formula

```
score = vector_weight * (1 / (k + rank_vector)) + keyword_weight * (1 / (k + rank_keyword))
```

Where `k` is typically 60.

## Anti-Patterns

- ❌ Don't use raw score addition without normalization
- ❌ Don't use fixed weights for all domains
- ❌ Don't ignore score calibration
SKILLEOF