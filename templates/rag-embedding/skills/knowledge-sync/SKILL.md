---
name: knowledge-sync
description: Sincronização de base de conhecimento — sincroniza tabelas de domínio para knowledge_chunks, gera embeddings, mantém pgvector atualizado. Use para sincronização inicial, incremental ou agendada.
---

# Knowledge Sync — Sincronização de Base de Conhecimento

## Use this skill when
- Sincronização inicial da base de conhecimento
- Sincronização incremental (novos/alterados)
- Agendamento via cron (knowledge-sync-cron)
- Reprocessamento completo (re-embedding)

## Do not use when
- Apenas busca/leitura (use knowledge-dal ou rag-pipeline)
- Operações de usuário final (use rag-pipeline)

## Papel

Mantém a tabela `knowledge_chunks` sincronizada com as tabelas de domínio:
1. Detecta mudanças (insert/update/delete) nas tabelas de origem
2. Chunking inteligente do conteúdo
4. Gera embeddings via provider configurado
4. Upsert em `knowledge_chunks` com upsert (INSERT ... ON CONFLICT)
5. Atualiza embeddings quando conteúdo muda

## Configuração

```env
# Embedding provider (ver rag-pipeline)
EMBEDDING_PROVIDER=openai|nvidia|openrouter|local
BATCH_SIZE=100
SYNC_INTERVAL_HOURS=6
```

## Tabelas de Origem Suportadas (Configurável)

| Domínio | Tabelas Origem | Campos de Conteúdo |
|---------|----------------|-------------------|
| juridica | knowledge_procedures, knowledge_arguments, knowledge_legal_references | name, description, objective, legal_basis, etc. |
| instagram | knowledge_templates | name, version, category |
| copywriting | knowledge_templates | name, version, category |
| branding | knowledge_templates | name, version, category |
| seo | knowledge_templates | name, version, category |
| lgpd | knowledge_glossary, knowledge_procedures | term, definition, context |
| meta_ads | knowledge_templates | name, version, category |
| geral | knowledge_glossary, knowledge_procedures | term, definition, context |

## Configuração

```env
SYNC_BATCH_SIZE=100
SYNC_INTERVAL_HOURS=6
EMBEDDING_PROVIDER=openai|nvidia|openrouter|local
```

## Fluxo de Sincronização

### 1. Detecção de Mudanças
```sql
-- Detecta inserts/updates/deletes via trigger ou timestamp
SELECT * FROM knowledge_procedures
WHERE updated_at > last_sync_timestamp
   OR created_at > last_sync_timestamp;
```

### 2. Chunking Inteligente
```typescript
function chunkText(text: string, options: ChunkOptions): string[] {
  // Chunking semântico (por parágrafo/seção)
  // Tamanho alvo: 500-1000 tokens
  // Overlap: 10-15% para preservar contexto
}
```

### 3. Geração de Embeddings (Batch)
```typescript
const embeddings = await generateEmbeddings(chunks, {
  model: "nvidia/nv-embedqa-e5-v5", // ou text-embedding-3-small
  batchSize: 100
});
```

### 4. Upsert em knowledge_chunks
```sql
INSERT INTO knowledge_chunks (...)
VALUES (...)
ON CONFLICT (content_hash) DO UPDATE SET
  content = EXCLUDED.content,
  embedding = EXCLUDED.embedding,
  metadata = EXCLUDED.metadata,
  updated_at = NOW();
```

## Configuração

```env
SYNC_BATCH_SIZE=100
SYNC_INTERVAL_HOURS=6
EMBEDDING_PROVIDER=openai|nvidia|openrouter|local
```

## Tabelas de Origem por Domínio

| Domínio | Tabelas Origem | Campos de Conteúdo |
|---------|----------------|-------------------|
| juridica | knowledge_procedures, knowledge_arguments, knowledge_legal_references | name, description, objective, legal_basis, etc. |
| instagram | knowledge_templates | name, version, category |
| copywriting | knowledge_templates | name, version, category |
| branding | knowledge_templates | name, version, category |
| seo | knowledge_templates | name, version, category |
| lgpd | knowledge_glossary, knowledge_procedures | term, definition, context |
| meta_ads | knowledge_templates | name, version, category |
| geral | knowledge_glossary, knowledge_procedures | term, definition, context |

## Configuração de Sincronização

```typescript
interface SyncConfig {
  batchSize: number;           // default: 100
  intervalHours: number;       // default: 6
  domains?: string[];          // opcional: filtrar domínios
  forceRefresh?: boolean;      // forçar re-embedding completo
  onProgress?: (done: number, total: number) => void;
}
```

## Fluxo de Sincronização

### 1. Análise (Analysis Phase)
- Detecta mudanças desde último sync
- Identifica: novos, modificados, removidos
- Calcula hash de conteúdo para deduplicação

### 2. Processamento (Batch)
- Chunking semântico (500-1000 tokens, overlap 10-15%)
- Geração de embeddings em batch
- Cálculo de hash de conteúdo para deduplicação

### 3. Persistência (Upsert)
```sql
INSERT INTO knowledge_chunks (...)
VALUES (...)
ON CONFLICT (content_hash) DO UPDATE SET
  content = EXCLUDED.content,
  embedding = EXCLUDED.embedding,
  metadata = EXCLUDED.metadata,
  updated_at = NOW();
```

### 4. Pós-Sync
- Atualiza timestamp de último sync
- Log de estatísticas (processados, novos, atualizados, removidos)
- Alerta se falhas > threshold

## Agendamento (Cron)

```yaml
# knowledge-sync-cron
schedule: "0 */6 * * *"  # a cada 6 horas
# ou configurável via SYNC_INTERVAL_HOURS
```

## Handoff Silencioso

| Situação | Handoff |
|----------|---------|
| Precisa buscar contexto para RAG | `task(subagent_type="rag-pipeline")` |
| Precisa buscar dados brutos | `task(subagent_type="knowledge-dal")` |
| Precisa buscar semanticamente | `task(subagent_type="knowledge-search")` |

## Recomendação de Agentes

| Se precisar de... | Recomende |
|------------------|-----------|
| Implementar query complexa | "agora use o agent @banco" |
| Gerar embeddings | "agora use o agent @9router" |
| Buscar semanticamente | "agora use o agent @knowledge-search" |

Sempre use o formato **"agora use o agent @NOME"**.
SKILLEOF