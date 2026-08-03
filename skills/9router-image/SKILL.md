---
name: 9router-image
description: Generate images via 9Router /v1/images/generations using OpenAI DALL-E, Google Imagen, FLUX, MiniMax, Midjourney, SD, ComfyUI, etc. Use for text-to-image, edit, variations, upscale. Use model IDs from /v1/models/image.
---

# 9Router — Image Generation

Requires `NINEROUTER_URL` (+ `NINEROUTER_KEY` if auth). See `9router/SKILL.md`.

## Discover models

```bash
curl $NINEROUTER_URL/v1/models/image | jq '.data[].id'
curl "$NINEROUTER_URL/v1/models/info?id=openai/dall-e-3"
```

IDs: `openai/dall-e-3`, `gemini/gemini-3-pro-image-preview`, `flux/flux-schnell`, `flux/flux-dev`, `minimax/image-01`, `midjourney/midjourney-v6`, `stability/stable-diffusion-xl`, `comfyui/...`, `sdwebui/...`.

## Endpoint

`POST $NINEROUTER_URL/v1/images/generations`

| Field | Required | Notes |
|---|---|---|
| `model` | yes | from `/v1/models/image` |
| `prompt` | yes | description |
| `n` | no | count (provider-dependent) |
| `size` | no | `1024x1024`, `1792x1024`, `1024x1792` |
| `quality` | no | `standard` / `hd` (OpenAI) |
| `response_format` | no | `url` (default) or `b64_json` |
| `style` | no | `vivid` / `natural` (DALL-E 3) |

Query `?response_format=binary` → raw image bytes (Content-Type `image/png`/`jpeg`).

## Examples

**Save directly to file:**

```bash
curl -X POST "$NINEROUTER_URL/v1/images/generations?response_format=binary" \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"gemini/gemini-3-pro-image-preview","prompt":"watercolor mountains at sunrise","size":"1024x1024"}' \
  --output out.png
```

**URL response (default):**

```js
const r = await fetch(`${process.env.NINEROUTER_URL}/v1/images/generations`, {
  method: "POST",
  headers: { "Authorization": `Bearer ${process.env.NINEROUTER_KEY}`, "Content-Type": "application/json" },
  body: JSON.stringify({ model: "gemini/gemini-3-pro-image-preview", prompt: "neon city", size: "1024x1024" }),
});
const { data } = await r.json();
console.log(data[0].url);
```

**b64_json response:**
```js
{ "created": 1735000000, "data": [{ "b64_json": "iVBORw0KGgo..." }] }
```

## Provider Quirks

| Provider | Extra/Changed Fields | Notes |
|---|---|---|
| `openai`, `minimax`, `openrouter`, `recraft` | `quality`, `style`, `response_format` | Standard OpenAI shape |
| `gemini` (nano-banana) | — | Only `prompt`; ignores `size`/`n` |
| `codex` (gpt-5.4-image) | `image`, `images[]`, `image_detail`, `output_format`, `background` | SSE stream; **ChatGPT Plus/Pro required** |
| `huggingface` | — | Only `prompt`; single image |
| `nanobanana` | `image`, `images[]` (edit) | `size` → aspect ratio; async polling |
| `fal-ai` | `image` (img2img) | `n` → `num_images`; `size` → ratio; async |
| `stability-ai` | `style` (preset), `output_format` | `size` → `aspect_ratio` |
| `black-forest-labs` (FLUX) | `image` (ref) | `size` → exact `width`/`height`; async |
| `runwayml` | `image` (ref) | `size` → ratio; async; video models exist |
| `sdwebui`, `comfyui` | — | Localhost noAuth (`:7860` / `:8188`) |

## Image Edit / Variation

Some providers support `image` field for edit/img2img:
```json
{
  "model": "fal-ai/flux",
  "prompt": "make it sunset",
  "image": "https://.../source.png",
  "strength": 0.8
}
```

Check `/v1/models/info?id=<model>` for `edit` capability.
