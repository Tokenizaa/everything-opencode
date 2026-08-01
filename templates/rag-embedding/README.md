# Template RAG + Embedding (Baseado no DefesAi)

Sistema completo de RAG (Retrieval-Augmented Generation) com embeddings usando NVIDIA + 9Router, compatível com Supabase/pgvector.

## 📦 O que inclui

```
rag-embedding/
├── skills/                    # Skills OpenCode (DAL + RAG Pipeline)
│   ├── knowledge-dal/         # Data Access Layer (Supabase)
│   ├── rag-pipeline/          # RAG Pipeline (query → embedding → search → context)
│   ├── knowledge-sync/        # Sincronização de base de conhecimento
│   └── knowledge-search/      # Busca semântica + híbrida
├── edge-functions/            # Supabase Edge Functions
│   ├── knowledge-embeddings/  # Gera embeddings via NVIDIA/9Router
│   ├── knowledge-search/      # Busca semântica + híbrida (vetorial + BM25)
│   ├── knowledge-sync/        # Sincronização de base de conhecimento
│   └── knowledge-sync-cron/   # Cron job de sincronização
├── prompts/                   # Prompts de RAG
│   ├── rag-system-prompt.md
│   ├── rag-query-expansion.md
│   ├── rag-hybrid-search.md
│   └── rag-response-template.md
├── config/
│   ├── supabase-schema.sql    # Schema pgvector + tabelas
│   ├── edge-function-config.json
│   └── env.example
└── prompts/
    └── rag-prompts.md
```

## 🚀 Instalação Rápida

```bash
# 1. Copiar skills para ~/.config/opencode/skills/
cp -r skills/* ~/.config/opencode/skills/

# 2. Instalar dependências
npm install @supabase/supabase-js

# 3. Configurar variáveis de ambiente (ver config/env.example)
cp config/env.example .env.local
# Editar .env.local com suas chaves

# 4. Aplicar schema no Supabase
psql -h <host> -U postgres -d <db> -f config/supabase-schema.sql

# 4. Deploy Edge Functions (Supabase)
supabase functions deploy knowledge-embeddings
supabase functions deploy knowledge-search
supabase functions deploy knowledge-sync
supabase functions deploy knowledge-sync-cron
```

## ⚙️ Configuração (config/env.example)

```env
# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key

# NVIDIA (embeddings)
NVIDIA_API_KEY=your_nvidia_api_key
NVIDIA_EMBED_MODEL=nvidia/nv-embedqa-e5-v5

# 9Router (fallback/gratuito)
NINEROUTER_URL=http://localhost:20128
NINEROUTER_KEY=your_9router_key
NINEROUTER_EMBED_MODEL=nvidia/nv-embedqa-e5-v5

# App
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
```

## 🏗️ Estrutura do Banco (Supabase/pgvector)

```sql
-- Extensões
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Tabela de chunks de conhecimento
CREATE TABLE knowledge_chunks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  domain VARCHAR(50) NOT NULL,
  source_table TEXT NOT NULL,
  source_id TEXT NOT NULL,
  source_type TEXT NOT NULL,
  title TEXT,
  content TEXT NOT NULL,
  content_hash CHAR(64) UNIQUE NOT NULL,
  metadata JSONB DEFAULT '{}',
  embedding VECTOR(1024),
  owner_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índice vetorial (HNSW)
CREATE INDEX ON knowledge_chunks USING hnsw (embedding vector_cosine_ops)
  WITH (m = 16, ef_construction = 64);

-- Índices auxiliares
CREATE INDEX ON knowledge_chunks (domain);
CREATE INDEX ON knowledge_chunks (source_table, source_id);
CREATE INDEX ON knowledge_chunks (content_hash);

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

-- RLS
ALTER TABLE knowledge_chunks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own chunks"
  ON knowledge_chunks FOR SELECT
  USING (auth.uid() = owner_id);

CREATE POLICY "Users can insert own chunks"
  ON knowledge_chunks FOR INSERT
  WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can update own chunks"
  ON knowledge_chunks FOR UPDATE
  USING (auth.uid() = owner_id);

-- Função de busca vetorial
CREATE OR REPLACE FUNCTION search_knowledge_chunks(
  query_embedding VECTOR(1024),
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
) LANGUAGE sql AS $$
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
```

## 🎯 Skills OpenCode (em skills/)

### 1. knowledge-dal — Data Access Layer
```yaml
# skills/knowledge-dal/SKILL.md
- findService(slug)
- listActiveServices()
- findInfractionByCode()
- findArgumentsByProcedure()
- findLegalReference()
- findTemplates()
- findDeadlines()
- findGlossaryTerm()
- ... (tudo do knowledge-skills do DefesAi)
```

### 2. rag-pipeline (Core RAG)
```yaml
# skills/rag-pipeline/SKILL.md
- searchKnowledge(query, options) → RAGContext
- embedText(text) → number[]
- searchSimilarChunks(query, options) → RAGChunk[]
- buildContext(chunks, query) → RAGContext
```

### 3. knowledge-sync
```yaml
# skills/knowledge-sync/SKILL.md
- syncKnowledgeBase(owner_id, domains?)
- scheduleSync(cron)
- processBatch(chunks)
```

### 4. knowledge-search
```yaml
# skills/knowledge-search/SKILL.md
- search(query, options) → RAGSearchResult
- hybridSearch(query, options) → RAGSearchResult
```

## 🔧 Edge Functions (Supabase)

### knowledge-embeddings
```typescript
// Gera embeddings via NVIDIA/9Router
// Input: chunks[] → salva no pgvector
// Suporta: NVIDIA (nv-embedqa-e5-v5) + 9Router fallback
```

### knowledge-search
```typescript
// Busca semântica + híbrida (vetorial + BM25)
// Filtros: domain, source_table, threshold, top_k
```

### knowledge-sync
```typescript
// Sincroniza tabelas de domínio → knowledge_chunks
// Domínios: juridica, instagram, copywriting, branding, seo, lgpd, meta_ads, geral
```

## 🚀 Como usar no projeto

### 1. No agente @backend
```typescript
import { skill } from "opencode";

async function generateContent(topic: string) {
  // 1. Carrega skill de RAG
  await skill({ name: "rag-pipeline" });
  
  // 2. Busca contexto relevante
  const context = await searchKnowledge(topic, {
    domains: ["juridica", "copywriting"],
    useCase: "generation",
    topK: 5
  });
  
  // 2. Gera conteúdo com contexto
  const content = await generateWithContext(topic, context.contextText);
  return content;
}
```

### 2. No agente @design
```typescript
// Busca referências visuais
const visualRefs = await searchKnowledge("landing page SaaS", {
  domains: ["branding", "seo"],
  useCase: "generation"
});
```

### 3. No agente @marketing
```typescript
const context = await searchKnowledge("campanha Black Friday", {
  domains: ["meta_ads", "copywriting"],
  useCase: "generation"
});
```

## 📋 Variáveis de Ambiente Necessárias

```env
# Supabase
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=xxx

# NVIDIA (embeddings primários)
NVIDIA_API_KEY=xxx
NVIDIA_EMBED_MODEL=nvidia/nv-embedqa-e5-v5

# 9Router (fallback gratuito)
NINEROUTER_URL=http://localhost:20128
NINEROUTER_KEY=xxx
NINEROUTER_EMBED_MODEL=nvidia/nv-embedqa-e5-v5

# App
NEXT_PUBLIC_SUPABASE_URL=xxx
NEXT_PUBLIC_SUPABASE_ANON_KEY=xxx
```

## 📋 Checklist de Deploy

- [ ] Schema SQL aplicado no Supabase
- [ ] Edge Functions deployadas (4 functions)
- [ ] Skills copiadas para `~/.config/opencode/skills/`
- [ ] Variáveis de ambiente configuradas
- [ ] Teste: `curl $NINEROUTER_URL/api/health`
- [ ] Teste embedding: `curl -X POST $NINEROUTER_URL/v1/embeddings ...`

## 📚 Referências
- [DefesAi RAG Implementation](https://github.com/Tokenizaa/everything-opencode/tree/main/templates/rag-embedding)
- [NVIDIA Embeddings API](https://docs.nvidia.com/nim/embeddings/)
- [Supabase pgvector](https://supabase.com/docs/guides/database/vector-columns)
- [pgvector docs](https://github.com/pgvector/pgvector)

---

## 📋 Resumo do que instalar

| Componente | Tipo | Status |
|------------|------|--------|
| Skills (4) | OpenCode skills | ✅ Pronto |
| Edge Functions | 4 (embeddings, search, sync, cron) | ✅ Pronto |
| SQL Schema | pgvector + RLS + HNSW | ✅ Pronto |
| Prompts | 4 arquivos | ✅ Pronto |
| Config | env.example + schema SQL | ✅ Pronto |

---

**Próximo passo:** Quer que eu crie o repositório `rag-embedding-template` no GitHub com tudo isso pronto para `npx degit` ou `git clone`?