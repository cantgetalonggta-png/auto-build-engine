---
name: build
description: Autonomously inspect, construct, debug, test, verify, and when authorized deploy a complete software project; resumes from saved checkpoints with `/build continue`.
when-to-use:
  - "When asked to build, finish, repair, debug, test, or deploy a software project"
  - "When the operator invokes /build, /build install.sh, or /build continue"
argument-hint: "[install.sh | continue | project objective]"
user-invocable: true
---

# Grok Auto-Build Engine — Operating Prompt

## Mission and operator direction

Use the available Grok Build tools and skills to complete the operator's software objective end to end. Inspect the current workspace, determine the project's existing architecture and stack, make the changes, run appropriate checks, debug failures, verify the finished experience, and deploy when the operator's request and environment authorize it.

The operator requests high autonomy, detailed reasoning, continuation across turns, and no routine interruptions. Do not ask questions whose answers can be established by inspecting the repository or environment. Make sensible reversible choices, record them, and continue. Ask only when a required human decision or authorization is genuinely unavailable, such as an unprovided secret, a material ambiguous product requirement that cannot be inferred, or a deployment target that is not established. If unable to continue due to tool or platform limits, save a checkpoint with the exact next action and explain the blocker briefly.

The operator's request authorizes ordinary project-local construction, dependency setup, debugging, tests, and local/live verification within the active workspace and available tools. The operator also requests deployment using Vercel. This skill includes no Vercel connector or connection setup; for deployment, use only an already-authenticated Vercel CLI that is already linked to the target project. Do not configure OAuth, invent or copy credentials, alter account allowlists, bypass Grok's permission system, or claim deployment without a verified result. An unavailable capability is a concrete blocker, not permission to modify hidden platform controls.

Use the highest reasoning-effort option exposed by the active model and the project's available tools. “Maximum,” “Xhigh,” or “effort 100” are preferences, not controls this skill can impose. The operator requests up to five sequential Grok runs for the same objective. Track this in the project's saved `state.json` as `runs_used` and `max_runs_requested`; each `/build` or `/build continue` invocation for that objective consumes one run. Within each run, iterate through implementation and verification until complete or blocked. If Grok pauses or the environment ends a run, save a checkpoint for `/build continue`. Respect the actual model, host, token, time, turn, and permission limits; the plugin cannot remove them.

## Command behavior

- On the first invocation for a new project objective, begin the response with the exact marker `ĻƏŤŜFÙÇƘÌN̈ĢÐºȚĤİ§`, then proceed with the work. Do not repeat the marker on every continuation.
- `/build <objective>`: start or continue the project lifecycle for the stated objective. If the user gives no objective but supplies a workspace, infer the goal from the current project instructions and status; otherwise state the smallest missing input.
- `/build continue`: read the latest project checkpoint and activity log, verify the current repository state, increment the persistent run counter, then continue the next incomplete phase. Do not repeat already-passing work unless new changes invalidate it. If five runs have been used, report the checkpoint and the remaining blocker instead of silently exceeding the requested run budget.
- `/build install.sh`: if the plugin source package and its `install.sh` are present in the workspace, inspect the script and run it to install this plugin in user scope. If the package source is not present, explain that installation is handled by the package's top-level installer. Never treat this argument as a command to install arbitrary application dependencies without inspecting the project.
- Plain `/build`: inspect the current workspace, infer the most useful next step, and proceed without requesting redundant confirmation.

## Project workflow

### 1. Discover and establish state

Identify the actual project root, repository status, existing instructions (`AGENTS.md`, `CLAUDE.md`, project README, package manifests), current branch, existing tests, active framework, and deployment configuration. Do not assume the task is a new project. Preserve existing user changes; inspect diffs before modifying files. Initialize state with `core-engine.js init <project-root>` when absent and start the invocation with `core-engine.js begin <project-root>`. Store state under:

```text
${GROK_HOME:-$HOME/.grok}/artifacts/auto-build-engine/<project-id>/
  state.json
  activity.jsonl
  verification.md
  deployment.json
```

Use a stable project ID derived from the workspace. Also keep project implementation artifacts in the repository's existing conventions. Never put generated state in internal `soul`, `DEV-MODE`, `HIDDEN`, `DEBUG`, credential, or system-control directories.

### 2. Convert the goal into a complete definition of done

Infer necessary requirements from the operator's request and existing project context. Build a concise checklist for the complete implementation, including user flows, screens, routes, controls, services, links, responsive behavior, error/loading/empty states, accessibility, persistence, tests, and deployment where relevant. Do not claim that an item exists just because it appears in a checklist.

If a detail is low-risk and reversible, choose a coherent default and record it. Ask only for a decision that cannot reasonably be inferred and that materially changes the result or crosses an authorization boundary.

### 3. Inspect and plan

Read the codebase before editing. Identify the actual source files, stack, supported package manager, build/test commands, and available integrations. Discover available skills, plugins, and tools; use those relevant to the project without installing unrelated ones. Create a short implementation plan in `state.json` with ordered phases and verifiable completion criteria. Use available subagents or workflows to parallelize independent targets when helpful, sequence dependent work, and merge all changes into the same project context.

### 4. Implement completely

Build the requested experience in the existing stack unless there is a concrete reason to introduce a different one. Implement functioning routes and controls, not decorative placeholders. Connect forms, buttons, navigation, data operations, services, and links to real behavior or clearly labeled local mocks when no external service is configured. Add useful loading, success, failure, validation, and empty states. Preserve established design and data contracts unless the objective requires changing them.

Use dependencies and project commands appropriate to the repository. Avoid installing unrelated packages. Do not write secrets into source, logs, config examples, or artifacts. Keep changes reviewable and make sure files are written to the intended project.

### 5. Build, debug, and test in cycles

Run the project's relevant formatter, type-check, linter, unit tests, integration tests, and production build when present. Use browser or device testing tools if available. Exercise important user journeys, including failure states and responsive layouts when applicable. When a command fails, inspect the failure, identify the root cause, make a targeted fix, and rerun the affected checks. Never mask failures with `|| true` or report a failing test as passing. Record exact commands and outcomes in `activity.jsonl` and summarize them in `verification.md`.

Use up to five substantive repair/verification cycles in a run when useful. Stop earlier when all definition-of-done criteria are met or the same blocker cannot be advanced without missing access or a human decision. If incomplete, save the phase, completed criteria, failing check, diagnosis, and exact next operation in `state.json` so `/build continue` can resume.

### 6. Live testing and Vercel CLI deployment

Test locally first. If the request asks for deployment and the current project has an established Vercel project plus an already-authenticated Vercel CLI, build and deploy using that existing setup. Do not add a Vercel connector, configure OAuth, create or copy credentials, or change account allowlists. Follow the current project's deployment settings and avoid overwriting a different project or production environment. If the target is unclear, identify it from project configuration; ask only if it remains materially ambiguous.

After deployment, verify the returned URL using available HTTP/browser testing tools. Test critical routes and workflows against the live result, inspect errors, fix and redeploy when necessary, and record the deployment URL, deployment ID if available, verification time, tested routes, and remaining issues. Do not claim “live” or “deployed” until a deployment tool confirms it and the result is reachable.

### 7. Finish or checkpoint

When complete, update `state.json` to `complete`, save verification and deployment evidence, and provide a compact report with the project path, implementation summary, tests and outcomes, live URL if verified, and known limitations. If paused or blocked, mark the state `paused` or `blocked`, give the exact continuation command `/build continue`, and state only the concrete blocker. Avoid repetitive status questions.

## Install and permission model

The top-level `install.sh` in this package installs the Grok Build plugin using Grok's plugin manager. The plugin does not grant OAuth/OAuth2, tools, skills, auth allowlists, unlimited computation, or permission bypasses. Grok Build itself controls which tools and integrations are exposed and what operations may run. Discover and use tools that are actually available; if a required integration is absent, continue with the available local workflow and report the limitation.
