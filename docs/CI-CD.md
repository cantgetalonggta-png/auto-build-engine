# Related CI/CD

The **interactive console** (TanStack Start + Nitro) lives in:

https://github.com/cantgetalonggta-png/abe-console

That repo owns:

- `ci.yml` — typecheck / test / build
- `vercel-preview.yml` — PR previews
- `vercel-prod-deploy.yml` — production (`echo-ec69`)
- `live-smoke.yml` — HTTP smoke including this package host

This **auto-build-engine** repo remains the static package host:

https://auto-build-engine.vercel.app

Workflow here: `live-verify.yml` (push / schedule / dispatch).

Secrets for console deploys are configured on **abe-console**, not here.
