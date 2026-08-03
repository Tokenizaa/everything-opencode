---
name: 9router-stt
description: Speech-to-text via 9Router using FREE providers: NVIDIA, Groq, Gemini, Edge TTS (for STT), OpenRouter, Hugging Face. Use for transcription, subtitles, voice notes. Model IDs from /v1/models/stt.
---

# 9Router — Free Speech-to-Text (NVIDIA + 9router Free Tier)

Requires `NINEROUTER_URL` (+ `NINEROUTER_KEY`). See `9router/SKILL.md`.

## Free STT Models on 9router

### NVIDIA (Free)
| Model ID | Description |
|---|---|
| `nvidia/fastpitch` | FastPitch TTS (not STT - check) |
| `nvidia/tacotron2` | Tacotron2 TTS (not STT - check) |

**Note**: NVIDIA currently provides TTS models on 9router. For STT, use other free providers below.

### Free Tier STT Providers

| Provider | Models | Free Limit | Best For |
|---|---|---|---|
| **Groq** | `groq/whisper-large-v3`, `groq/whisper-large-v3-turbo`, `groq/distil-whisper-large-v3-en` | **Free** (fast) | Fastest transcription |
| **Gemini** | `gemini/gemini-2.5-flash`, `gemini/gemini-2.5-pro`, `gemini/gemini-2.5-flash-lite` | **Free tier** | Multilingual, long audio |
| **Deepgram** | `deepgram/nova-3`, `deepgram/nova-2`, `deepgram/whisper-large` | Free tier | Streaming, real-time |
| **OpenRouter** | `openrouter/openai/whisper-large-v3`, `openrouter/groq/whisper-large-v3-turbo` | Free tier | Proxy access |
| **Hugging Face** | `huggingface/openai/whisper-large-v3`, `huggingface/openai/whisper-small` | Free tier | Open models |
| **NVIDIA** | `nvidia/parakeet-ctc-1.1b` | **Free** | ASR, CTC-based |

---

## Discover

```bash
curl "$NINEROUTER_URL/v1/models/stt" | jq '.data[] | select(.owned_by=="groq" or .owned_by=="gemini" or .owned_by=="nvidia" or .owned_by=="deepgram" or .owned_by=="openrouter" or .owned_by=="huggingface") | {id, owned_by}'
```

---

## Endpoint

`POST $NINEROUTER_URL/v1/audio/transcriptions` (multipart/form-data)

| Field | Required | Notes |
|---|---|---|
| `model` | yes | from `/v1/models/stt` |
| `file` | yes | audio (mp3, wav, m4a, webm, ogg, flac) |
| `language` | no | ISO-639-1 (e.g., `en`, `vi`, `pt`) |
| `prompt` | no | hint text to guide transcription |
| `response_format` | no | `json` (default) / `text` / `verbose_json` / `srt` / `vtt` |
| `temperature` | no | 0–1 |

---

## Examples

### Groq Whisper (Fastest, Free)
```bash
curl -X POST "$NINEROUTER_URL/v1/audio/transcriptions" \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -F "model=groq/whisper-large-v3-turbo" \
  -F "file=@audio.mp3" \
  -F "language=en"
```

### NVIDIA Parakeet (Free)
```bash
curl -X POST "$NINEROUTER_URL/v1/audio/transcriptions" \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -F "model=nvidia/parakeet-ctc-1.1b" \
  -F "file=@audio.wav" \
  -F "language=en"
```

### Gemini (Free Tier)
```bash
curl -X POST "$NINEROUTER_URL/v1/audio/transcriptions" \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -F "model=gemini/gemini-2.5-flash" \
  -F "file=@audio.mp3" \
  -F "language=vi"
```

### Deepgram (Free Tier)
```bash
curl -X POST "$NINEROUTER_URL/v1/audio/transcriptions" \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -F "model=deepgram/nova-3" \
  -F "file=@audio.mp3" \
  -F "response_format=verbose_json"
```

### SRT/VTT Subtitles
```bash
curl -X POST "$NINEROUTER_URL/v1/audio/transcriptions" \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -F "model=groq/whisper-large-v3-turbo" \
  -F "file=@audio.mp3" \
  -F "response_format=srt" \
  --output subtitles.srt
```

---

## JS Example

```js
import { createReadStream } from "node:fs";
import { FormData } from "formdata-node";

const form = new FormData();
form.append("model", "groq/whisper-large-v3-turbo");
form.append("file", new Blob([await readFile("audio.mp3")]), "audio.mp3");
form.append("language", "en");
form.append("response_format", "srt");

const r = await fetch(`${process.env.NINEROUTER_URL}/v1/audio/transcriptions`, {
  method: "POST",
  headers: { "Authorization": `Bearer ${process.env.NINEROUTER_KEY}` },
  body: form,
});

const srt = await r.text();
await writeFile("subtitles.srt", srt);
```

---

## Response Shapes

**Default (`json`):**
```json
{ "text": "Xin chào, đây là bản ghi âm." }
```

**`verbose_json`:**
```json
{
  "text": "Xin chào...",
  "language": "vi",
  "duration": 12.5,
  "segments": [
    { "id": 0, "start": 0.0, "end": 3.2, "text": "Xin chào" },
    { "id": 1, "start": 3.2, "end": 6.1, "text": "đây là bản ghi âm" }
  ]
}
```

**`srt` / `vtt`:** Returns subtitle text directly.

---

## Provider Comparison (Free)

| Provider | Model | Speed | Free Limit | Streaming | Best For |
|---|---|---|---|---|---|
| **Groq** | `whisper-large-v3-turbo` | ⚡⚡⚡ Fastest | Free | ❌ | Batch, speed |
| **Groq** | `distil-whisper-large-v3-en` | ⚡⚡⚡⚡ | Free | ❌ | English only, speed |
| **NVIDIA** | `parakeet-ctc-1.1b` | ⚡⚡ | Free | ❌ | ASR, CTC |
| **Gemini** | `gemini-2.5-flash` | ⚡ | Free tier | ❌ | Multilingual, long |
| **Deepgram** | `nova-3` | ⚡⚡ | Free tier | ✅ | Real-time, streaming |
| **OpenRouter** | Proxy to Groq/Gemini | Varies | Free tier | ❌ | Proxy access |

---

## JS Streaming (Groq doesn't stream, use for batch)

```js
const form = new FormData();
form.append("model", "groq/whisper-large-v3-turbo");
form.append("file", new Blob([await readFile("audio.mp3")]), "audio.mp3");
form.append("response_format", "verbose_json");

const r = await fetch(`${process.env.NINEROUTER_URL}/v1/audio/transcriptions`, {
  method: "POST",
  headers: { "Authorization": `Bearer ${process.env.NINEROUTER_KEY}` },
  body: form,
});
const { text, segments } = await r.json();
```

---

## Long Audio Handling

- **Chunk audio** into < 25 MB segments (Whisper limit)
- **Use ffmpeg** to split: `ffmpeg -i long.mp3 -f segment -segment_time 600 -c copy chunk%03d.mp3`
- **Transcribe in parallel** (Groq is fast)
- **Merge segments** with timestamps

---

## Quick Selection

| Need | Free Model |
|---|---|
| **Fastest** | `groq/whisper-large-v3-turbo` |
| **English only, fastest** | `groq/distil-whisper-large-v3-en` |
| **NVIDIA ASR** | `nvidia/parakeet-ctc-1.1b` |
| **Multilingual, long** | `gemini/gemini-2.5-flash` |
| **Real-time/streaming** | `deepgram/nova-3` |

---

## Anti-Patterns (Avoid Paid)

| ❌ Paid | Why |
|---|---|
| OpenAI Whisper API | Requires paid key |
| AssemblyAI | Paid plans |
| Speechmatics | Enterprise |
| Rev AI | Paid |
| Azure Speech | Paid |
| AWS Transcribe | Paid |
| Google Cloud Speech | Paid |
| AWS Transcribe | Paid |
