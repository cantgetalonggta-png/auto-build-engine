# Deployment status

| Check | Result |
|---|---|
| Production URL | **https://auto-build-engine.vercel.app** — HTTP 200, package host live |
| GitHub source | https://github.com/cantgetalonggta-png/auto-build-engine |
| Connected Grok Vercel team (`echo-ec69`) | List OK; **create project forbidden (403)** on this connector |
| Sandbox Vercel CLI `whoami` | Unauthenticated (no token in shell) |
| Agent skills | `vercel-labs/agent-skills` installed global (9 skills) |
| Temporary claim deploy | Available via `vercel deploy --temporary` when re-issued |

## Agent setup (from vercel.com/get-started.md)

1. **CLI**: installed (`vercel` 56+ / npx vercel@latest).
2. **Guidance**: standalone skills installed (`npx skills add vercel-labs/agent-skills --global -y --agent '*'`). Plugin path needs a supported agent binary (blocked here).
3. **MCP / connector**: Vercel is connected in Grok (list teams/projects/deployments). Project *create* on team `echo-ec69` returned 403.
4. **Project link**: production hostname already serves this package. Re-deploys: push `main` if the Vercel project is Git-linked to this repo, or claim a temporary deploy into the account that owns `auto-build-engine`.
