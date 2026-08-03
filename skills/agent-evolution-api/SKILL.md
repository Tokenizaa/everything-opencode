---
name: agent-evolution-api
description: Integração WhatsApp via Evolution API — instâncias, envio de mensagens, webhooks, grupos, chatbot. Orquestra a skill evolution-api para automação WhatsApp.
---

# Agent: Evolution API — WhatsApp Integration

## Use this skill when
- Criar/gerenciar instâncias WhatsApp via Evolution API
- Enviar mensagens (texto, mídia, áudio, listas, botões, reações)
- Configurar webhooks e event listeners
- Gerenciar grupos e contatos
- Integrar com Typebot, Chatwoot, Dify ou OpenAI
- Automação de atendimento WhatsApp

## Do not use when
- Tarefa não relacionada a WhatsApp
- Frontend/backend genérico (use @backend, @frontend)

## Papel

Orquestrador da integração WhatsApp via Evolution API (Baileys / WhatsApp Business API).
Gerencia instâncias, mensagens, webhooks e chatbot.

## Skills Operacionais Relacionadas

- `evolution-api` — skill completa de integração (312 linhas: instâncias, auth, mensagens, webhooks)
- `whatsapp-automation` — automação WhatsApp Business (se aplicável)
- `agent-backend` — para lógica de integração no backend

## Configuração

```env
EVOLUTION_URL=https://seu-servidor-evolution.com
EVOLUTION_API_KEY=seu-global-api-key
# ou token por instância
```

## Autenticação

```bash
# Todas as requisições usam header apikey
curl --request <METHOD> \
  --url https://<SERVER_URL>/<path>/{instanceName} \
  --header 'Content-Type: application/json' \
  --header 'apikey: <api-key>' \
  --data '<json-body>'
```

## Fluxo de trabalho

1. Identifique a necessidade (instância, mensagem, webhook, grupo)
2. Carregue a skill `evolution-api`: `skill({ "name": "evolution-api" })`
3. Consulte os endpoints específicos na skill
4. Implemente a integração

## Exemplos rápidos

### Criar instância
```bash
curl --request POST \
  --url https://$EVOLUTION_URL/instance/create \
  --header 'apikey: $EVOLUTION_API_KEY' \
  --header 'Content-Type: application/json' \
  --data '{"instanceName": "meu-bot", "qrcode": true}'
```

### Enviar mensagem de texto
```bash
curl --request POST \
  --url https://$EVOLUTION_URL/message/sendText/{instanceName} \
  --header 'apikey: $EVOLUTION_API_KEY' \
  --header 'Content-Type: application/json' \
  --data '{"number": "5511999990000", "text": "Olá!"}'
```

## Handoff Silencioso

| Situação | Handoff |
|----------|---------|
| Lógica de negócio da integração | `task(subagent_type="backend")` |
| Persistir conversas | `task(subagent_type="banco")` |
| UI do painel WhatsApp | `task(subagent_type="frontend")` |
| IA para chatbot | `task(subagent_type="9router")` |

## Recomendação de Agentes

| Se precisar de... | Recomende |
|------------------|-----------|
| Backend da integração | "agora use o agent @backend" |
| Banco de conversas | "agora use o agent @banco" |
| IA do chatbot | "agora use o agent @9router" |

Sempre use o formato **"agora use o agent @NOME"**.
