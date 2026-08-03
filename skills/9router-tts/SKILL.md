---
name: 9router-tts
description: Text-to-speech via 9Router using FREE providers only: NVIDIA (FastPitch, Tacotron2) + 9router combo free tier (Edge TTS, Google TTS, MiniMax, Gemini, local-device). Use when the user wants free TTS without paid API keys.
---

# 9Router — Free TTS (NVIDIA + 9router Combo)

**Requires**: `NINEROUTER_URL` (and `NINEROUTER_KEY` if auth enabled). See main 9router skill for setup.

## Free TTS Models Available on 9router

### NVIDIA (Free via 9router)
| Model ID | Description |
|---|---|
| `nvidia/fastpitch` | FastPitch - fast, high-quality TTS |
| `nvidia/tacotron2` | Tacotron 2 - classic high-quality TTS |

### 9router Combo / Free Tier Providers

| Provider | Model IDs | Notes |
|---|---|---|
| **edge-tts** | `edge-tts/en-US-AriaNeural`, `edge-tts/vi-VN-HoaiMyNeural`, `edge-tts/en-US-GuyNeural`, `edge-tts/en-GB-SoniaNeural`, `edge-tts/zh-CN-XiaoxiaoNeural`, `edge-tts/zh-CN-YunxiNeural`, `edge-tts/fr-FR-DeniseNeural`, `edge-tts/de-DE-KatjaNeural`, `edge-tts/ja-JP-NanamiNeural`, `edge-tts/ko-KR-SunHiNeural` | **Free** (Microsoft Edge TTS) |
| **google-tts** | `google-tts/en`, `google-tts/vi`, `google-tts/pt`, `google-tts/es`, `google-tts/fr`, `google-tts/de`, `google-tts/ja`, `google-tts/ko`, `google-tts/zh-CN`, `google-tts/zh-TW`, + 30 more languages | **Free tier** (Google Cloud) |
| **minimax** | `minimax/speech-01-hd`, `minimax/speech-01-turbo`, `minimax/speech-02-hd`, `minimax/speech-02-turbo`, `minimax/speech-2.6-hd`, `minimax/speech-2.6-turbo`, `minimax/speech-2.8-hd`, `minimax/speech-2.8-turbo` | Free tier available |
| **minimax-cn** | `minimax-cn/speech-01-hd`, `minimax-cn/speech-01-turbo`, `minimax-cn/speech-02-hd`, `minimax-cn/speech-02-turbo`, `minimax-cn/speech-2.6-hd`, `minimax-cn/speech-2.6-turbo`, `minimax-cn/speech-2.8-hd`, `minimax-cn/speech-2.8-turbo` | Chinese optimized, free tier |
| **gemini** | `gemini/gemini-3.1-flash-tts-preview`, `gemini/gemini-2.5-flash-preview-tts`, `gemini/gemini-2.5-pro-preview-tts` | Free tier (Google AI) |
| **minimax-cn** | Chinese TTS variants | Free tier |
| **edge-tts** | 400+ voices (filter with `?lang=vi`, `?lang=en`, etc.) | **Free** (Microsoft) |
| **google-tts** | 40+ languages (`google-tts/en`, `google-tts/vi`, `google-tts/pt`, etc.) | Free tier (Google) |
| **local-device** | `local-device/default` | System TTS (no auth) |

---

## Discover Available Voices

```bash
# List all free TTS models
curl "$NINEROUTER_URL/v1/models/tts" | jq '.data[] | select(.owned_by=="nvidia" or .owned_by=="edge-tts" or .owned_by=="google-tts" or .owned_by=="minimax" or .owned_by=="gemini") | {id, owned_by}'

# List voices for a provider
curl "$NINEROUTER_URL/v1/audio/voices?provider=edge-tts&lang=en"
curl "$NINEROUTER_URL/v1/audio/voices?provider=google-tts&lang=vi"
```

---

## Endpoint

`POST $NINEROUTER_URL/v1/audio/speech`

| Field | Required | Notes |
|---|---|---|
| `model` | yes | Voice ID from `/v1/models/tts` (e.g., `nvidia/fastpitch`, `edge-tts/en-US-AriaNeural`) |
| `input` | yes | Text to speak |

Query `?response_format=mp3` (default, raw bytes) or `?response_format=json` (`{audio: base64, format}`).

---

## Examples

### NVIDIA FastPitch (Free)
```bash
curl -X POST "$NINEROUTER_URL/v1/audio/speech" \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"nvidia/fastpitch","input":"Hello from NVIDIA FastPitch"}' \
  --output nvidia-fastpitch.mp3
```

### NVIDIA Tacotron2 (Free)
```bash
curl -X POST "$NINEROUTER_URL/v1/audio/speech" \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"nvidia/tacotron2","input":"Tacotron 2 from NVIDIA"}' \
  --output nvidia-tacotron2.mp3
```

### Edge TTS - Free (Microsoft)
```bash
curl -X POST "$NINEROUTER_URL/v1/audio/speech" \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"edge-tts/en-US-AriaNeural","input":"Free TTS from Microsoft Edge"}' \
  --output edge-tts.mp3
```

### Vietnamese (Free)
```bash
# Edge TTS Vietnamese
curl -X POST "$NINEROUTER_URL/v1/audio/speech" \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"edge-tts/vi-VN-HoaiMyNeural","input":"Xin chào từ Edge TTS"}' \
  --output vi-edge.mp3

# Google TTS Vietnamese (free tier)
curl -X POST "$NINEROUTER_URL/v1/audio/speech" \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"google-tts/vi","input":"Xin chào từ Google TTS"}' \
  --output vi-google.mp3
```

### MiniMax Chinese (Free Tier)
```bash
curl -X POST "$NINEROUTER_URL/v1/audio/speech" \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"minimax-cn/speech-02-hd","input":"免费中文语音合成"}' \
  --output minimax-cn.mp3
```

### Gemini TTS (Free Tier)
```bash
curl -X POST "$NINEROUTER_URL/v1/audio/speech" \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"gemini/gemini-2.5-flash-preview-tts","input":"Gemini free TTS"}' \
  --output gemini-tts.mp3
```

### Local Device (No Auth, Local System TTS)
```bash
curl -X POST "$NINEROUTER_URL/v1/audio/speech" \
  -H "Content-Type: application/json" \
  -d '{"model":"local-device/default","input":"Using local system TTS"}' \
  --output local-tts.mp3
```

---

## JS Examples

```js
import { writeFile } from "node:fs/promises";

async function tts(model, input, output) {
  const r = await fetch(`${process.env.NINEROUTER_URL}/v1/audio/speech`, {
    method: "POST",
    headers: { 
      "Authorization": `Bearer ${process.env.NINEROUTER_KEY}`, 
      "Content-Type": "application/json" 
    },
    body: JSON.stringify({ model, input }),
  });
  await writeFile(output, Buffer.from(await r.arrayBuffer()));
}

// Free NVIDIA
await tts("nvidia/fastpitch", "NVIDIA FastPitch free", "nvidia.mp3");
await tts("nvidia/tacotron2", "NVIDIA Tacotron2 free", "nvidia2.mp3");

// Free tier providers
await tts("edge-tts/en-US-AriaNeural", "Free Microsoft TTS", "edge.mp3");
await tts("google-tts/vi", "Google TTS Vietnamese free", "google-vi.mp3");
await tts("minimax/speech-02-hd", "MiniMax free tier", "minimax.mp3");
await tts("gemini/gemini-2.5-flash-preview-tts", "Gemini free TTS", "gemini.mp3");

// Local device (no auth needed)
await tts("local-device/default", "Local system TTS", "local.mp3");
```

---

## Response Shape

Default (`response_format=mp3`): raw audio bytes (`Content-Type: audio/mp3`)

`?response_format=json`:
```json
{ "audio": "SUQzBAAAA...", "format": "mp3" }
```

---

## Anti-Patterns (Avoid Paid Providers)

| ❌ Paid Provider | Why Avoid |
|---|---|
| OpenAI (`openai/tts-1`, `tts-1-hd`, `gpt-4o-mini-tts`) | Requires paid API key |
| ElevenLabs (`el/...`) | Requires paid subscription |
| Deepgram (`dg/...`) | Requires paid token |
| Google Cloud TTS (paid) | Requires billing account |
| Hyperbolic, Inworld, Cartesia, PlayHT | Paid |
| Coqui, Tortoise (local) | Requires GPU/compute |

---

## Quick Voice Selection Guide

| Language | Recommended Free Model |
|---|---|
| English | `nvidia/fastpitch`, `edge-tts/en-US-AriaNeural`, `google-tts/en` |
| Vietnamese | `edge-tts/vi-VN-HoaiMyNeural`, `google-tts/vi` |
| Portuguese | `edge-tts/pt-BR-FranciscaNeural`, `google-tts/pt` |
| Spanish | `edge-tts/es-ES-ElviraNeural`, `google-tts/es` |
| French | `edge-tts/fr-FR-DeniseNeural`, `google-tts/fr` |
| Chinese | `minimax-cn/speech-02-hd`, `edge-tts/zh-CN-XiaoxiaoNeural`, `google-tts/zh-CN` |
| Japanese | `edge-tts/ja-JP-NanamiNeural`, `google-tts/ja` |
| Korean | `edge-tts/ko-KR-SunHiNeural`, `google-tts/ko` |
| German | `edge-tts/de-DE-KatjaNeural`, `google-tts/de` |

---

## Anti-Patterns

- ❌ Using paid OpenAI/ElevenLabs/Deepgram keys
- ❌ Hardcoding paid model IDs
- ❌ Ignoring free tier limits (check provider quotas)
- ❌ Not chunking long text (>4000 chars) for edge-tts/google-tts
