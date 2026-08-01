---
name: knowledge-sync-cron
description: Cron job para sincronização automática da base de conhecimento. Agenda sincronização periódica via pg_cron ou Supabase Cron.
---

# Knowledge Sync Cron — Agendamento Automático

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

## Agendamento

### pg_cron (Supabase)

```sql
-- A cada 6 horas
SELECT cron.schedule(
  'knowledge-sync-6h',
  '0 */6 * * *',
  $$
  SELECT net.http_post(
    url := 'https://your-project.supabase.co/functions/v1/knowledge-sync',
    headers := jsonb_build_object(
      'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key'),
      'Content-Type', 'application/json'
    ),
    body := jsonb_build_object(
      'domains', ARRAY['juridica', 'marketing', 'instagram', 'copywriting'],
      'batch_size', 100
    )::jsonb
  );
  $$
);
```

### Supabase Cron (Dashboard)

1. Settings → Database → Cron Jobs
2. Schedule: `0 */6 * * *` (a cada 6 horas)
3. Function: `knowledge-sync` (Edge Function)
4. Body: 
```json
{
  "domains": ["juridica", "marketing", "instagram", "copywriting"],
  "batch_size": 100
}
```

### GitHub Actions (Alternativa)

```yaml
# .github/workflows/knowledge-sync.yml
name: Knowledge Sync
on:
  schedule:
    - cron: '0 */6 * * *'  # a cada 6 horas
  workflow_dispatch:

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Trigger Sync
        run: |
          curl -X POST https://your-project.supabase.co/functions/v1/knowledge-sync \
            -H "Authorization: Bearer ${{ secrets.SUPABASE_SERVICE_ROLE_KEY }}" \
            -H "Content-Type: application/json" \
            -d '{"domains":["juridica","marketing"],"batch_size":100}'
```

---

## Monitoramento

### Logs
```bash
# Ver logs da sincronização
supabase functions logs knowledge-sync --follow
```

### Métricas
```sql
-- Ver último sync
SELECT * FROM sync_logs ORDER BY created_at DESC LIMIT 10;

-- Stats de chunks
SELECT domain, count(*) as chunks, max(updated_at) as last_update
FROM knowledge_chunks
GROUP BY domain;
```

---

## Configuração de Variáveis

```env
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=xxx
NVIDIA_API_KEY=xxx
NINEROUTER_URL=http://localhost:20128
NINEROUTER_KEY=sk-...
NIVIDIA_EMBED_MODEL=nvidia/nv-embedqa-e5-v5
NINEROUTER_EMBED_MODEL=nvidia/nv-embedqa-e5-v5

# Cron
SYNC_INTERVAL_HOURS=6
BATCH_SIZE=100
```
SKILLEOF