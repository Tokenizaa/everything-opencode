---
name: rag-pipeline
description: RAG Pipeline Service — Orquestra: Query Embedding → Busca Semântica/Híbrida → Injeção de Contexto → Geração. Usa embeddings via 9Router/NVIDIA + pgvector no PostgreSQL.
---

# RAG Pipeline Service

## Use this skill when
- Precisar de busca semântica/híbrida no banco de conhecimento
- Gerar contexto para geração de conteúdo (RAG)
- Busca híbrida (vetorial + BM25/keyword)
- Injeção de contexto em prompts de LLM

## Do not use when
- Apenas busca por ID exato (use knowledge-dal)
- Operações de escrita/escrita no banco (use knowledge-dal)

## Papel

Orquestra o pipeline completo de RAG:
1. **Embedding** da query via provider configurável (OpenAI, NVIDIA, 9Router, etc.)
2. **Busca Vetorial** no pgvector (HNSW/IVFFlat)
3. **Busca Híbrida** (vetorial + BM25/keyword)
3. **Rerank** opcional (Cross-Encoder via provider)
5. **Contexto** para injeção no prompt LLM

## Configuração

Requer variáveis de ambiente (exemplos):

```env
# Embedding Provider (escolha um)
EMBEDDING_PROVIDER=openai|nvidia|openrouter|local

# OpenAI
OPENAI_API_KEY=sk-...
OPENAI_EMBED_MODEL=text-embedding-3-small

# NVIDIA
NVIDIA_API_KEY=xxx
NVIDIA_EMBED_MODEL=nvidia/nv-embedqa-e5-v5

# 9Router (gateway multi-provider)
NINEROUTER_URL=http://localhost:20128
NINEROUTER_KEY=sk-...
NINEROUTER_EMBED_MODEL=nvidia/nv-embedqa-e5-v5

# OpenRouter
OPENROUTER_API_KEY=xxx
OPENROUTER_EMBED_MODEL=openai/text-embedding-3-small

# Local (sentence-transformers via Python)
LOCAL_EMBED_MODEL=sentence-transformers/all-MiniLM-L6-v2
```

## Pipeline

### 1. Embedding da Query
```typescript
const queryEmbedding = await embedText(query, { model: "text-embedding-3-small" });
// Usa provider configurado (OpenAI, NVIDIA, 9Router, local, etc.)
```

### 2. Busca Vetorial (pgvector/pgvector)
```sql
SELECT *, 1 - (embedding <=> $1) AS similarity
FROM knowledge_chunks
WHERE 1 - (embedding <=> $query_embedding) > $threshold
  AND (domain = $domain OR $domain IS NULL)
ORDER BY embedding <=> $query_embedding
LIMIT $topK;
```

### 3. Busca Híbrida (Vetorial + BM25/Keyword)
```typescript
const vectorResults = await vectorSearch(queryEmbedding, options);
const keywordResults = await keywordSearch(query, options);
const merged = hybridMerge(vectorResults, keywordResults, {
  vectorWeight: 0.7,
  keywordWeight: 0.3,
  rrfK: 60  // Reciprocal Rank Fusion
});
```

### 4. Rerank (opcional, via Cross-Encoder)
```typescript
const reranked = await rerank(query, chunks, { 
  model: "cross-encoder/ms-marco-MiniLM-L-6-v2",
  topK: 10 
});
```

### 5. Context Injection
```typescript
const context = buildContext(chunks, query);
// Injeta no prompt: "Contexto relevante:\n{contextText}\n\nPergunta: {query}"
```

## Types

```typescript
type KnowledgeDomain = string; // livre, ex: "legal", "marketing", "docs", "code"

interface RAGSearchOptions {
  embedding: number[];
  domain?: string;
  sourceTable?: string;
  topK?: number;
  threshold?: number;
  filter?: Record<string, unknown>;
}

interface HybridSearchOptions {
  query: string;
  domain?: string;
  topK?: number;
  vectorWeight?: number;  // default 0.7
  keywordWeight?: number; // default 0.3
  rrfK?: number;          // default 60
}

interface RAGContext {
  contextText: string;      // Texto concatenado para injeção
  chunks: RAGChunk[];       // Chunks individuais
  summary: string;          // Resumo do que foi recuperado
}

interface RAGChunk {
  id: string;
  domain?: string;
  sourceTable?: string;
  sourceId?: string;
  sourceType?: string;
  title?: string;
  content: string;
  metadata: Record<string, unknown>;
  similarity: number;
}
```

## Provider de Embedding (Configurável)

A skill detecta automaticamente o provider baseado nas env vars:

| Provider | Env Vars | Modelos Suportados |
|----------|----------|-------------------|
| OpenAI | `OPENAI_API_KEY` | `text-embedding-3-small`, `text-embedding-3-large`, `text-embedding-ada-002` |
| NVIDIA | `NVIDIA_API_KEY` | `nvidia/nv-embedqa-e5-v5`, `nvidia/nv-embedqa-mistral-7b-v2` |
| 9Router | `NINEROUTER_URL`, `NINEROUTER_KEY` | Qualquer modelo do 9Router |
| OpenRouter | `OPENROUTER_API_KEY` | Qualquer modelo do OpenRouter |
| Local (Python) | `LOCAL_EMBED_MODEL` | sentence-transformers, etc. |

A skill detecta automaticamente qual provider usar baseado nas env vars disponíveis.

## Uso

```typescript
await skill({ name: "rag-pipeline" });

// Busca simples
const context = await searchKnowledge("como recorrer multa velocidade", {
  domains: ["juridico"],
  useCase: "generation",
  topK: 5
});

// Busca híbrida
const results = await hybridSearch("como recorrer multa velocidade", {
  domains: ["juridico"],
  useCase: "compliance",
  topK: 10
});

// Geração com contexto
const result = await generateWithContext("como recorrer multa velocidade", context.contextText);
```

## Handoff Silencioso

| Situação | Handoff |
|----------|---------|
| Precisa buscar dados brutos | `task(subagent_type="knowledge-dal")` |
| Precisa sincronizar base | `task(subagent_type="knowledge-sync")` |
| Precisa buscar semanticamente | `task(subagent_type="knowledge-search")` |

## Recomendação de Agentes

| Se precisar de... | Recomende |
|------------------|-----------|
| Buscar dados brutos | "agora use o agent @banco" |
| Gerar embedding | "agora use o agent @9router" |
| Sincronizar base | "agora use o agent @knowledge-sync" |

Sempre use o formato **"agora use o agent @NOME"**.
SKILLEOF