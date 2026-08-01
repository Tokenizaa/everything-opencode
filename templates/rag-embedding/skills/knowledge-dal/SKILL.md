---
name: knowledge-dal
description: Data Access Layer genérica para base de conhecimento com pgvector/PostgreSQL. Fornece acesso padronizado a documentos, chunks, embeddings e metadados. Use SEMPRE antes de acessar o banco vetorial diretamente.
---

# Knowledge DAL — Camada de Acesso a Dados Genérica

## Use this skill when
- Precisar consultar/manipular documentos, chunks, embeddings e metadados no banco vetorial
- Qualquer agente que precise acessar a base de conhecimento vetorial
- Operações CRUD em documentos, chunks, embeddings e metadados

## Do not use when
- Operações que não envolvem o banco vetorial/knowledge base
- Operações diretas no banco sem passar pela DAL

## Papel

Camada de acesso a dados genérica para base de conhecimento com pgvector/PostgreSQL.
Todas as consultas ao banco vetorial passam por aqui — NUNCA acesse o banco diretamente.

## Configuração Obrigatória

Requer variáveis de ambiente:
- `DATABASE_URL` ou `POSTGRES_URL` — conexão PostgreSQL com pgvector
- Opcional: `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` (se usar Supabase)

## Estrutura Esperada do Banco

```sql
-- Tabela principal de chunks/documentos
CREATE TABLE knowledge_chunks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  domain VARCHAR(100),           -- domínio/categoria (ex: "legal", "marketing", "docs")
  source_table TEXT,             -- tabela origem
  source_id TEXT,                -- ID na tabela origem
  source_type TEXT,              -- tipo: "document", "chunk", "section", etc.
  title TEXT,                    -- título opcional
  content TEXT NOT NULL,         -- conteúdo textual
  content_hash CHAR(64) UNIQUE,  -- hash SHA256 do conteúdo
  metadata JSONB DEFAULT '{}',   -- metadados flexíveis
  embedding VECTOR(1536),        -- embedding vector (dimensão configurável)
  embedding_model VARCHAR(100),  -- modelo usado (ex: "nvidia/nv-embedqa-e5-v5")
  owner_id UUID,                 -- owner (opcional, para multi-tenancy)
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índice vetorial HNSW
CREATE INDEX ON knowledge_chunks USING hnsw (embedding vector_cosine_ops)
  WITH (m = 16, ef_construction = 64);

-- Índices auxiliares
CREATE INDEX ON knowledge_chunks (domain);
CREATE INDEX ON knowledge_chunks (source_table, source_id);
CREATE INDEX ON knowledge_chunks (content_hash);
```

## Interface (Skill API)

```typescript
interface KnowledgeDAL {
  // Documentos/Chunks
  upsertChunk(input: UpsertChunkInput): Promise<KnowledgeChunk>;
  getChunk(id: string): Promise<KnowledgeChunk | null>;
  deleteChunk(id: string): Promise<void>;
  listChunks(filter: ListChunksFilter): Promise<KnowledgeChunk[]>;
  
  // Busca vetorial
  searchSimilar(queryEmbedding: number[], options: SearchOptions): Promise<SearchResult[]>;
  
  // Busca híbrida (vetorial + texto)
  hybridSearch(query: string, options: HybridSearchOptions): Promise<SearchResult[]>;
  
  // CRUD básico
  upsertDocument(input: UpsertDocumentInput): Promise<Document>;
  getDocument(id: string): Promise<Document | null>;
  deleteDocument(id: string): Promise<void>;
  listDocuments(filter: ListDocumentsFilter): Promise<Document[]>;
  
  // Embeddings
  generateEmbedding(text: string, model?: string): Promise<number[]>;
  batchGenerateEmbeddings(texts: string[]): Promise<number[][]>;
  
  // Utilitários
  chunkText(text: string, options?: ChunkOptions): string[];
  hashContent(content: string): string;
}

interface KnowledgeChunk {
  id: string;
  domain?: string;
  source_table?: string;
  source_id?: string;
  source_type?: string;
  title?: string;
  content: string;
  content_hash: string;
  metadata: Record<string, unknown>;
  embedding?: number[];
  embedding_model?: string;
  domain?: string;
  created_at: string;
  updated_at: string;
}

interface SearchOptions {
  embedding: number[];
  domain?: string;
  source_table?: string;
  top_k?: number;
  threshold?: number;
  filter?: Record<string, unknown>;
}

interface HybridSearchOptions {
  query: string;
  domain?: string;
  top_k?: number;
  vector_weight?: number;
  text_weight?: number;
}

interface UpsertChunkInput {
  domain?: string;
  source_table?: string;
  source_id?: string;
  source_type?: string;
  title?: string;
  content: string;
  metadata?: Record<string, unknown>;
  domain?: string;
  embedding?: number[];
  embedding_model?: string;
}

interface UpsertDocumentInput {
  source_table: string;
  source_id: string;
  title: string;
  content: string;
  metadata?: Record<string, unknown>;
  domain?: string;
}
```

## Regras Obrigatórias

- **NUNCA** acesse o banco vetorial diretamente — use esta skill
- Todas as queries passam por aqui para consistência e auditoria
- Erros do banco são propagados — trate com try/catch
- Sempre gere `content_hash` (SHA256) para deduplicação

## Handoff Silencioso

| Situação | Handoff |
|----------|---------|
| Precisa buscar contexto para RAG | `task(subagent_type="rag-pipeline")` |
| Precisa sincronizar dados | `task(subagent_type="knowledge-sync")` |
| Precisa buscar semanticamente | `task(subagent_type="knowledge-search")` |

## Recomendação de Agentes

| Se precisar de... | Recomende |
|------------------|-----------|
| Query complexa no banco | "agora use o agent @banco" |
| Gerar embeddings | "agora use o agent @9router" |
| Sincronizar base | "agora use o agent @knowledge-sync" |

Sempre use o formato **"agora use o agent @NOME"**.
SKILLEOF