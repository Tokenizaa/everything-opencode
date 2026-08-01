---
name: knowledge-embeddings
description: Edge Function — Gera embeddings via NVIDIA/9Router e salva no pgvector. Recebe chunks, gera embeddings em batch, salva no pgvector.
---

# Knowledge Embeddings — Edge Function

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

## Entrada (POST /v1/embeddings)

```json
{
  "chunks": [
    {
      "id": "uuid",
      "content": "texto do chunk",
      "domain": "juridico",
      "source_table": "knowledge_procedures",
      "source_id": "123",
      "source_type": "procedure",
      "title": "Título opcional",
      "metadata": { "custom": "metadata" },
      "owner_id": "uuid-opcional"
    }
  ],
  "model": "nvidia/nv-embedqa-e5-v5",
  "batch_size": 100
}
```

## Resposta

```json
{
  "processed": 10,
  "failed": 0,
  "errors": []
}
```

## Implementação (Deno/Edge Runtime)

```typescript
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

interface EmbeddingRequest {
  chunks: Array<{
    id?: string;
    content: string;
    domain: string;
    source_table: string;
    source_id: string;
    source_type: string;
    title?: string;
    metadata?: Record<string, unknown>;
    owner_id?: string;
  }>;
  model?: string;
  batch_size?: number;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { chunks, model, batch_size = 100 } = await req.json();
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

    for (let i = 0; i < chunks.length; i += batch_size) {
      const batch = chunks.slice(i, i + batch_size);
      
      // Gerar embeddings (tenta NVIDIA primeiro, fallback 9Router)
      let embeddings: number[][];
      try {
        embeddings = await generateEmbeddingsNVIDIA(batch.map(c => c.content), model);
      } catch (e) {
        console.warn("NVIDIA falhou, tentando 9Router:", e.message);
        embeddings = await generateEmbeddings9Router(batch.map(c => c.content));
      }

      // Upsert no Supabase
      const chunksToUpsert = batch.map((chunk, idx) => ({
        id: chunk.id || crypto.randomUUID(),
        domain: chunk.domain,
        source_table: chunk.source_table,
        source_id: chunk.source_id,
        source_type: chunk.source_type,
        title: chunk.title,
        content: chunk.content,
        content_hash: await computeContentHash(chunk.content),
        metadata: chunk.metadata || {},
        embedding: embeddings[idx],
        embedding_model: model,
        domain: chunk.domain,
        source_table: chunk.source_table,
        source_id: chunk.source_id,
        source_type: chunk.source_type,
        title: chunk.title,
        content: chunk.content,
        metadata: chunk.metadata || {},
        owner_id: chunk.owner_id,
      });

      const { error } = await supabase
        .from("knowledge_chunks")
        .upsert(chunksToUpsert, { onConflict: "content_hash" });

      if (error) {
        failed += batch.length;
        errors.push({ batch: i, error: error.message });
      } else {
        processed += batch.length;
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

// Helpers
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