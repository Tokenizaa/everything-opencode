---
name: 9router-chat
description: OpenAI-compatible chat via 9Router /v1/chat/completions. Supports streaming, tools/functions, reasoning, response_format, seed, logprobs, multi-modal. Auto-fallback across all configured providers (OpenAI, Anthropic, Groq, DeepSeek, Google, xAI, etc.) — no provider code needed.
---

# 9Router — Chat / Code-Gen

Requires `NINEROUTER_URL` (+ `NINEROUTER_KEY` if auth enabled). See `9router/SKILL.md` for setup.

## Discover models

```bash
curl $NINEROUTER_URL/v1/models | jq '.data[].id'
# or filter to chat
curl $NINEROUTER_URL/v1/models | jq '.data[] | select(.kind=="chat") | .id'
```

IDs like `openai/gpt-5`, `anthropic/claude-3.5-sonnet`, `groq/llama-3.3-70b-versatile`, `google/gemini-2.5-pro`, `deepseek/deepseek-r1`.

## Endpoint

`POST $NINEROUTER_URL/v1/chat/completions`

| Field | Required | Notes |
|---|---|---|
| `model` | yes | from `/v1/models` (e.g. `openai/gpt-5`) |
| `messages` | yes | `[{role,content}]` |
| `stream` | no | `true` → SSE (`data: ...\n\n`) |
| `temperature` | no | 0–2 |
| `max_tokens` | no | or `max_completion_tokens` |
| `tools` | no | OpenAI function-calling schema |
| `tool_choice` | no | `"auto"`, `"none"`, `{type:"function",...}` |
| `response_format` | no | `{type:"json_object"}` or JSON Schema |
| `seed` | no | deterministic output |
| `logprobs` | no | `true` + `top_logprobs` |
| `reasoning` | no | `{"effort":"high|medium|low"}` for reasoning models |

## Streaming

```bash
curl -N -X POST $NINEROUTER_URL/v1/chat/completions \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"openai/gpt-5","messages":[{"role":"user","content":"Hello"}],"stream":true}'
```

SSE frames: `data: {"choices":[{"delta":{"content":"..."}}]}\n\n`; ends with `data: [DONE]`.

## Tools / Function Calling

```json
{
  "model": "openai/gpt-5",
  "messages": [{"role":"user","content":"What's the weather in Tokyo?"}],
  "tools": [{
    "type":"function",
    "function": {
      "name":"get_weather",
      "description":"Get current weather",
      "parameters": {
        "type":"object",
        "properties":{"city":{"type":"string"}},
        "required":["city"]
      }
    }
  }],
  "tool_choice":"auto"
}
```

Assistant returns `tool_calls`; you call the function, then send back:
```json
{"role":"tool","tool_call_id":"call_...","content":"{\"temp\":22,\"cond\":\"sunny\"}"}
```

## Structured Output (JSON Schema)

```json
{
  "model": "openai/gpt-5",
  "messages": [{"role":"user","content":"Extract name, email, phone from: ..."}],
  "response_format": {
    "type": "json_schema",
    "json_schema": {
      "name": "Contact",
      "schema": {
        "type": "object",
        "properties": {
          "name": {"type": "string"},
          "email": {"type": "string", "format": "email"},
          "phone": {"type": "string"}
        },
        "required": ["name","email"]
      },
      "strict": true
    }
  }
}
```

Returns valid JSON matching the schema.

## Reasoning Models

```json
{
  "model": "openai/o1",
  "messages": [{"role":"user","content":"Solve this step by step..."}],
  "reasoning": {"effort": "high"}
}
```

Returns `reasoning_content` in the message.

## Multi-modal (Vision)

```json
{
  "model": "openai/gpt-5",
  "messages": [{
    "role": "user",
    "content": [
      {"type":"text","text":"Describe this image"},
      {"type":"image_url","image_url":{"url":"data:image/png;base64,..."}}
    ]
  }]
}
```

## Code-Gen Tips

- Use `seed` for reproducible output
- `temperature: 0.2` for code, `0` for deterministic
- `response_format: {type: "json_object"}` for structured code output
- `tools` for running generated code in sandbox (see `sandbox-sdk`)
