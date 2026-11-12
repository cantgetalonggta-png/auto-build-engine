# Environment variables (Config vs Secret)

Source: [Vercel environment variables](https://vercel.com/docs/environment-variables) · [Config and Secret](https://vercel.com/docs/environment-variables/sensitive-environment-variables) · [Managing](https://vercel.com/docs/environment-variables/managing-environment-variables)

## Rules we follow

| Rule | Why |
|---|---|
| Classify every var as **Config** or **Secret** | Config stays readable to authorized roles; Secret is write-only after save |
| Never put keys in `VITE_*` / `NEXT_PUBLIC_*` | Those ship to the browser |
| Redeploy after env changes | Old deployments keep old values |
| Prefer dashboard or authenticated CLI | Sandbox `vercel whoami` may be unauthenticated |
| Total size ≤ 64 KB / deployment | Edge vars ≤ 5 KB each |

## Inventory

| Key | Type | Targets | Purpose |
|---|---|---|---|
| `XAI_API_KEY` | **Secret** | Production, Preview, Development | Server-side Grok calls |
| `XAI_MODEL` | Config | all | Model id (default `grok-3-latest`) |
| `XAI_BASE_URL` | Config | all | Default `https://api.x.ai/v1` |
| `GROK_CHAT_ENABLED` | Config | all | Toggle chat endpoint |
| `VITE_AUTH_ENABLED` | Config (client) | all | Preview auth gate |
| `VERCEL_TOKEN` | **Secret** (local/CI only) | Development | Optional CLI; never commit |

## Dashboard steps (production host)

1. Open [Vercel Dashboard](https://vercel.com/dashboard) → project that owns `auto-build-engine.vercel.app` (or the App Builder deploy).
2. **Settings → Environment Variables**.
3. Add each key. For `XAI_API_KEY` choose **Secret**. For model/flags choose **Config**.
4. Select environments (Production / Preview / Development).
5. **Save**, then **Redeploy** (env changes do not retrofit old deployments).

Bulk paste from a local `.env` is supported in the Add form (Import .env). Review type per row before saving.

## CLI (when authenticated)

```bash
# Secret
printf '%s' "$XAI_API_KEY" | vercel env add XAI_API_KEY production --type secret
# Config
printf '%s' 'grok-3-latest' | vercel env add XAI_MODEL production --type config

vercel env pull   # writes .env.local for Development
vercel env run -e preview -- npm run dev   # inject without writing disk
```

## Secure server use (this repo)

`src/lib/grok/chat.server.ts` exposes `chatWithGrok` via `createServerFn`. It reads `process.env.XAI_API_KEY` only on the server. Client components call the RPC; they never import the key.

## Troubleshooting

| Symptom | Fix |
|---|---|
| Dashboard change has no effect | Redeploy |
| Key undefined in browser | Expected for Secrets — only use on server |
| Preview wrong values | Check Preview target / branch overrides |
