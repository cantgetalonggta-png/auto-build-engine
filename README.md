# Grok Auto-Build Engine 2.2.0

User-invocable `/build` skill for Grok Build: inspect → implement → verify → checkpoint → continue.

## Install

```bash
./install.sh
```

Requires the Grok Build CLI (`grok`). Without it, install exits 127 by design.

## Commands

- `/build <objective>` — start or continue lifecycle (spends 1 run)
- `/build continue` — resume saved phase (spends 1 run)
- `/build install.sh` — run package installer when source is present (does not spend a run)

## Run budget

Default **5** runs per objective. Operator may **authorize another 50 runs**:

- `max_runs_requested` becomes **50**
- `runs_used` resets to **0**
- **phase, checklist, objective, and deploy notes are kept**

## Deploy notes

This repository hosts the plugin package and a static landing page.

- Vercel CLI deploy requires an authenticated account or `VERCEL_TOKEN`.
- Git → Vercel Dashboard import works without the sandbox CLI.
- The interactive console also runs inside Grok App Builder preview.

## Live status

See `DEPLOYMENT.md` for the latest host verification.
