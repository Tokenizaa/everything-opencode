-- Schema do Banco de Conhecimento com pgvector
-- Compatível com PostgreSQL 15+ + pgvector 0.5+

-- Extensões necessárias
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS pg_trgm;  -- para BM25/keyword search

-- ============================================================
-- TABELA PRINCIPAL: knowledge_chunks
-- ============================================================

CREATE TABLE knowledge_chunks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Classificação
  domain VARCHAR(100),                    -- domínio: juridico, marketing, docs, code, etc.
  source_table TEXT,                      -- tabela origem (ex: knowledge_procedures)
  source_id TEXT,                         -- ID na tabela origem
  source_type TEXT,                       -- tipo: document, chunk, section, procedure, etc.
  
  -- Conteúdo
  title TEXT,                             -- título opcional
  content TEXT NOT NULL,                  -- conteúdo textual completo
  content_hash CHAR(64) UNIQUE NOT NULL,  -- SHA256 hex do conteúdo (dedup)
  
  -- Metadados flexíveis
  metadata JSONB DEFAULT '{}',
  
  -- Embedding vetorial
  embedding VECTOR(1536),                 -- dimensão configurável (1536 para OpenAI, 1024 para NVIDIA)
  embedding_model VARCHAR(100),           -- modelo usado (ex: text-embedding-3-small, nvidia/nv-embedqa-e5-v5)
  
  -- Multi-tenancy (opcional)
  owner_id UUID,                          -- REFERENCES auth.users(id) se usar Supabase Auth
  
  -- Metadados
  domain VARCHAR(100),                    -- domínio: juridico, marketing, docs, code, etc.
  source_table TEXT,                      -- tabela origem (ex: knowledge_procedures)
  source_id TEXT,                         -- ID na tabela origem
  source_type TEXT,                       -- document, chunk, section, procedure, etc.
  title TEXT,                             -- título opcional
  content TEXT NOT NULL,                  -- conteúdo textual completo
  content_hash CHAR(64) UNIQUE NOT NULL,  -- SHA256 hex do conteúdo (dedup)
  
  metadata JSONB DEFAULT '{}',            -- metadados flexíveis
  embedding VECTOR(1536),                 -- dimensão configurável (1536 OpenAI, 1024 NVIDIA, etc.)
  embedding_model VARCHAR(100),           -- modelo usado (ex: text-embedding-3-small, nvidia/nv-embedqa-e5-v5)
  
  owner_id UUID,                          -- REFERENCES auth.users(id) se Supabase Auth
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- ÍNDICES
-- ============================================================

-- Índice vetorial HNSW (recomendado para pgvector 0.5+)
CREATE INDEX ON knowledge_chunks USING hnsw (embedding vector_cosine_ops)
  WITH (m = 16, ef_construction = 64);

-- Índice IVFFlat alternativo (se HNSW não disponível)
-- CREATE INDEX ON knowledge_chunks USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- Índices auxiliares
CREATE INDEX ON knowledge_chunks (domain);
CREATE INDEX ON knowledge_chunks (source_table, source_id);
CREATE INDEX ON knowledge_chunks (content_hash);
CREATE INDEX ON knowledge_chunks (domain);
CREATE INDEX ON knowledge_chunks (source_table, source_id);
CREATE INDEX ON knowledge_chunks (owner_id);
CREATE INDEX ON knowledge_chunks (embedding_model);

-- Índice GIN para metadata JSONB
CREATE INDEX ON knowledge_chunks USING GIN (metadata);

-- Trigger para updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_knowledge_chunks_updated_at
  BEFORE UPDATE ON knowledge_chunks
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- RLS (Row Level Security) - Supabase
-- ============================================================

ALTER TABLE knowledge_chunks ENABLE ROW LEVEL SECURITY;

-- Usuários podem ler próprios chunks
CREATE POLICY "Users can read own chunks"
  ON knowledge_chunks FOR SELECT
  USING (auth.uid() = owner_id);

-- Usuários podem inserir próprios chunks
CREATE POLICY "Users can insert own chunks"
  ON knowledge_chunks FOR INSERT
  WITH CHECK (auth.uid() = owner_id);

-- Usuários podem atualizar próprios chunks
CREATE POLICY "Users can update own chunks"
  ON knowledge_chunks FOR UPDATE
  USING (auth.uid() = owner_id);

-- Usuários podem deletar próprios chunks
CREATE POLICY "Users can delete own chunks"
  ON knowledge_chunks FOR DELETE
  USING (auth.uid() = owner_id);

-- Admin/Service role pode tudo (service_role bypassa RLS)
-- Service role key bypassa RLS automaticamente

-- ============================================================
-- FUNÇÃO DE BUSCA VETORIAL
-- ============================================================

-- Busca vetorial pura (cosine similarity)
CREATE OR REPLACE FUNCTION search_knowledge_chunks(
  query_embedding VECTOR(1536),
  match_threshold FLOAT DEFAULT 0.75,
  match_count INT DEFAULT 10,
  filter_domain TEXT[] DEFAULT NULL,
  filter_owner UUID DEFAULT NULL
)
RETURNS TABLE (
  id UUID,
  domain TEXT,
  source_table TEXT,
  source_id TEXT,
  source_type TEXT,
  title TEXT,
  content TEXT,
  metadata JSONB,
  similarity FLOAT
) LANGUAGE sql STABLE AS $$
  SELECT
    kc.id,
    kc.domain,
    kc.source_table,
    kc.source_id,
    kc.source_type,
    kc.title,
    kc.content,
    kc.metadata,
    1 - (kc.embedding <=> query_embedding) AS similarity
  FROM knowledge_chunks kc
  WHERE (filter_domain IS NULL OR kc.domain = ANY(filter_domain))
    AND (filter_owner IS NULL OR kc.owner_id = filter_owner)
    AND 1 - (kc.embedding <=> query_embedding) > match_threshold
  ORDER BY kc.embedding <=> query_embedding
  LIMIT match_count;
$$ LANGUAGE sql;

-- ============================================================
-- FUNÇÃO DE BUSCA HÍBRIDA (Vetorial + BM25 via pg_trgm)
-- ============================================================

CREATE OR REPLACE FUNCTION hybrid_search_knowledge_chunks(
  query_text TEXT,
  query_embedding VECTOR(1536),
  domain_filter TEXT[] DEFAULT NULL,
  top_k INT DEFAULT 10,
  vector_weight FLOAT DEFAULT 0.7,
  keyword_weight FLOAT DEFAULT 0.3,
  rrf_k INT DEFAULT 60
)
RETURNS TABLE (
  id UUID,
  domain TEXT,
  source_table TEXT,
  source_id TEXT,
  source_type TEXT,
  title TEXT,
  content TEXT,
  metadata JSONB,
  similarity FLOAT,
  score FLOAT
) LANGUAGE plpgsql AS $$
DECLARE
  vector_results RECORD;
  keyword_results RECORD;
  rrf_k INT := 60;
BEGIN
  -- Busca vetorial
  CREATE TEMP TABLE temp_vector AS
  SELECT
    kc.id,
    kc.domain,
    kc.source_table,
    kc.source_id,
    kc.source_type,
    kc.title,
    kc.content,
    kc.metadata,
    1 - (kc.embedding <=> query_embedding) AS similarity,
    ROW_NUMBER() OVER (ORDER BY kc.embedding <=> query_embedding) AS vector_rank
  FROM knowledge_chunks kc
  WHERE (filter_domain IS NULL OR kc.domain = ANY(domain_filter))
  ORDER BY kc.embedding <=> query_embedding
  LIMIT top_k;

  -- Busca keyword (pg_trgm similarity)
  CREATE TEMP TABLE temp_keyword AS
  SELECT
    kc.id,
    kc.domain,
    kc.source_table,
    kc.source_id,
    kc.source_type,
    kc.title,
    kc.content,
    kc.metadata,
    similarity(kc.content, query_text) AS keyword_sim,
    ROW_NUMBER() OVER (ORDER BY similarity(kc.content, query_text) DESC) AS keyword_rank
  FROM knowledge_chunks kc
  WHERE (filter_domain IS NULL OR kc.domain = ANY(domain_filter))
  ORDER BY similarity(kc.content, query_text) DESC
  LIMIT top_k;

  -- RRF (Reciprocal Rank Fusion)
  RETURN QUERY
  SELECT
    COALESCE(v.id, k.id) AS id,
    COALESCE(v.domain, k.domain) AS domain,
    COALESCE(v.source_table, k.source_table) AS source_table,
    COALESCE(v.source_id, k.source_id) AS source_id,
    COALESCE(v.source_type, k.source_type) AS source_type,
    COALESCE(v.title, k.title) AS title,
    COALESCE(v.content, k.content) AS content,
    COALESCE(v.metadata, k.metadata) AS metadata,
    COALESCE(v.similarity, 0) AS similarity,
    (vector_weight * (1.0 / (rrf_k + COALESCE(v.vector_rank, 999999))) +
     keyword_weight * (1.0 / (rrf_k + COALESCE(k.keyword_rank, 999999)))) AS score
  FROM temp_vector v
  FULL JOIN temp_keyword k ON v.id = k.id
  ORDER BY score DESC
  LIMIT top_k;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- TRIGGER PARA UPDATED_AT
-- ============================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_knowledge_chunks_updated_at
  BEFORE UPDATE ON knowledge_chunks
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- FUNÇÃO AUXILIAR: HASH DE CONTEÚDO
-- ============================================================

CREATE OR REPLACE FUNCTION compute_content_hash(content TEXT)
RETURNS CHAR(64) LANGUAGE sql IMMUTABLE AS $$
  SELECT encode(sha256(content::bytea), 'hex');
$$ LANGUAGE sql;

-- Trigger para auto-popular content_hash
CREATE OR REPLACE FUNCTION set_content_hash()
RETURNS TRIGGER AS $$
BEGIN
  NEW.content_hash := encode(sha256(NEW.content::bytea), 'hex');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_knowledge_chunks_content_hash
  BEFORE INSERT OR UPDATE ON knowledge_chunks
  FOR EACH ROW EXECUTE FUNCTION set_content_hash();

-- ============================================================
-- ÍNDICES ADICIONAIS PARA BUSCA HÍBRIDA
-- ============================================================

-- Índice GIN para busca textual (pg_trgm)
CREATE INDEX ON knowledge_chunks USING GIN (content gin_trgm_ops);
CREATE INDEX ON knowledge_chunks USING GIN (metadata);

-- Índice para busca por source_table + source_id
CREATE INDEX ON knowledge_chunks (source_table, source_id);

-- Índice para busca por embedding_model
CREATE INDEX ON knowledge_chunks (embedding_model);

-- Índice composto para queries comuns
CREATE INDEX ON knowledge_chunks (domain, source_table, source_id);