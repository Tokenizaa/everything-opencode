---
name: knowledge-sync
description: Edge Function — Sincronização de base de conhecimento. Sincroniza tabelas de domínio para knowledge_chunks, gera embeddings, mantém pgvector atualizado.
---

# Knowledge Sync — Edge Function

## Configuração

```env
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=xxx
NVIDIA_API_KEY=xxx
NINEROUTER_URL=http://localhost:20128
NINEROUTER_KEY=sk-...
NIVIDIA_EMBED_MODEL=nvidia/nv-embedqa-e5-v5
NINEROUTER_EMBED_MODEL=nvidia/nv-embedqa-e5-v5
```

## Entrada (POST /v1/sync)

```json
{
  "owner_id": "uuid",
  "domains": ["juridico", "marketing"],
  "force_refresh": false,
  "batch_size": 100
}
```

## Domínios Suportados

| Domínio | Tabelas Origem | Campos de Conteúdo |
|---|---|---|
| juridica | knowledge_procedures, knowledge_arguments, knowledge_legal_references | name, description, objective, legal_basis, etc. |
| instagram | knowledge_templates | name, version, category |
| copywriting | knowledge_templates | name, version, category |
| branding | knowledge_templates | name, version, category |
| seo | knowledge_templates | name, version, category |
| lgpd | knowledge_glossary, knowledge_procedures | term, definition, context |
| meta_ads | knowledge_templates | name, version, category |
| geral | knowledge_glossary, knowledge_procedures | term, definition, context |

---

## Endpoint

`POST /v1/sync`

## Entrada

```json
{
  "owner_id": "uuid",
  "domains": ["juridico", "marketing"],
  "force_refresh": false,
  "batch_size": 100
}
```

## Saída

```json
{
  "processed": 10,
  "failed": 0,
  "errors": []
}
```

---

## Implementação (Deno/Edge Runtime)

```typescript
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

interface SyncRequest {
  owner_id: string;
  domains?: string[];
  force_refresh?: boolean;
  batch_size?: number;
}

const DOMAIN_CONFIG = {
  juridica: {
    tables: [
      { table: "knowledge_procedures", type: "procedure", contentFields: ["name", "description", "objective", "legal_basis"] },
      { table: "knowledge_arguments", type: "argument", contentFields: ["title", "description", "when_to_use", "when_not_to_use", "requirements", "legal_basis", "related_jurisprudence", "required_documents", "notes"] },
      { table: "knowledge_templates", type: "template", contentFields: ["name", "version", "category"] },
      { table: "knowledge_template_sections", type: "template_section", contentFields: ["title"] },
      { table: "knowledge_legal_references", type: "legal_ref", contentFields: ["type", "number", "year", "title", "description"] },
      { table: "knowledge_flow_steps", type: "flow_step", contentFields: ["name", "description"] },
      { table: "knowledge_checklists", type: "checklist", contentFields: ["notes"] },
      { table: "knowledge_glossary", type: "glossary", contentFields: ["term", "definition", "context"] },
    ],
  },
  instagram: {
    tables: [
      { table: "knowledge_templates", type: "template", contentFields: ["name", "version", "category"] },
    ],
  },
  copywriting: {
    tables: [
      { table: "knowledge_templates", type: "template", contentFields: ["name", "version", "category"] },
    ],
  },
  // ... outros domínios
};

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { owner_id, domains, force_refresh, batch_size = 100 } = await req.json();
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const NVIDIA_API_KEY = Deno.env.get("NVIDIA_API_KEY");
    const NINEROUTER_URL = Deno.env.get("NINEROUTER_URL");
    const NINEROUTER_KEY = Deno.env.get("NINEROUTER_KEY");
    const NVIDIA_MODEL = Deno.env.get("NIVIDIA_EMBED_MODEL") || "nvidia/nv-embedqa-e5-v5";
    const NINEROUTER_EMBED_MODEL = Deno.env.get("NINEROUTER_EMBED_MODEL") || "nvidia/nv-embedqa-e5-v5";

    const NVIDIA_EMBED_URL = "https://integrate.api.nvidia.com/v1/embeddings";
    const NINEROUTER_EMBED_URL = `${NINEROUTER_URL}/v1/embeddings`;

    let processed = 0;
    let failed = 0;
    const errors = [];

    for (const domain of domains || Object.keys(DOMAIN_CONFIG)) {
      const config = DOMAIN_CONFIG[domain];
      if (!config) continue;

      for (const tableConfig of config.tables) {
        // Buscar dados da tabela origem
        let query = supabase.from(tableConfig.table).select("*");
        // TODO: adicionar filtro de updated_at se não force_refresh

        const { data: rows, error } = await query;
        if (error) {
          errors.push({ table: tableConfig.table, error: error.message });
          continue;
        }

        for (let i = 0; i < rows.length; i += batch_size) {
          const batch = rows.slice(i, i + batch_size);
          
          // Preparar chunks para embedding
          const chunks = batch.map(row => {
            const content = tableConfig.contentFields.map(f => row[f]).filter(Boolean).join("\n\n");
            return {
              id: crypto.randomUUID(),
              domain: domain,
              source_table: tableConfig.table,
              source_id: row.id,
              source_type: tableConfig.type,
              title: row.name || row.title,
              content: content,
              metadata: { /* metadados da linha */ },
              content_hash: await computeContentHash(content),
            };
          });

          // Gerar embeddings (NVIDIA -> 9Router fallback)
          let embeddings = await generateEmbeddingsNVIDIA(chunks.map(c => c.content), NVIDIA_MODEL);
          
          // Upsert no knowledge_chunks
          const chunksToUpsert = chunks.map((chunk, idx) => ({
            id: chunk.id,
            domain: chunk.domain,
            source_table: chunk.source_table,
            source_id: chunk.source_id,
            source_type: chunk.source_type,
            title: chunk.title,
            content: chunk.content,
            content_hash: chunk.content_hash,
            metadata: chunk.metadata,
            embedding: embeddings[idx],
            embedding_model: "nvidia/nv-embedqa-e5-v5",
            domain: chunk.domain,
            source_table: chunk.source_table,
            source_id: chunk.source_id,
            source_type: chunk.source_type,
            title: chunk.title,
            content: chunk.content,
            metadata: chunk.metadata,
          }));

          const { error } = await supabase
            .from("knowledge_chunks")
            .upsert(chunksToUpsert, { onConflict: "content_hash" });

          if (error) {
            failed += batch.length;
            errors.push({ table: tableConfig.table, error: error.message });
          } else {
            processed += batch.length;
          }
        }
      }
    }

    return new Response(JSON.stringify({ processed, failed, errors }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" }
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" }
    });
  }
});

// Helpers (mesmo do knowledge-embeddings)
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const NVIDIA_EMBED_URL = "https://integrate.api.nvidia.com/v1/embeddings";
const NINEROUTER_EMBED_URL = `${NINEROUTER_URL}/v1/embeddings`;

async function generateEmbeddingsNVIDIA(texts: string[], model: string): Promise<number[][]> {
  const response = await fetch(NVIDIA_EMBED_URL, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${NVIDIA_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model,
      input: texts,
      encoding_format: "float",
    }),
  });
  const data = await response.json();
  return data.data.map(d => d.embedding);
}

async function generateEmbeddings9Router(texts: string[]): Promise<number[][]> {
  const response = await fetch(`${NINEROUTER_URL}/v1/embeddings`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${NINEROUTER_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: "nvidia/nv-embedqa-e5-v5",
      input: texts,
      encoding_format: "float",
    }),
  });
  const data = await response.json();
  return data.data.map(d => d.embedding);
}

async function computeContentHash(content: string): Promise<string> {
  const encoder = new TextEncoder();
  const hash = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(content));
  return Array.from(new Uint8Array(hash)).map(b => b.toString(16).padStart(2, "0")).join("");
}

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
SKILLEOF