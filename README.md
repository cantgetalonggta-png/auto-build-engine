# Grok Auto-Build Engine — Plugin Package

This package turns the supplied autonomous-build concept into a native Grok Build plugin. It includes a user-invocable `/build` skill, a persistent five-run continuation counter, `/build continue` resume behavior, the requested package and manifest files, autonomy preferences, environment verification, bootstrap and Node-project pipeline scripts, and a checkpoint/state engine.

## Install and invoke

Extract the ZIP on the computer where Grok Build is installed, enter the extracted `Grok-Auto-Build-Engine-Install` folder, and run:

```bash
./install.sh
```

The installer validates and installs the local plugin through Grok Build's plugin manager, then enables it at user scope. It does not run a build in the current project. After installation, use `/build <objective>` to start work or `/build continue` to resume the latest saved project checkpoint. `/build install.sh` asks the skill to run the package installer when its source is available.

## Persistent state and continuation

Grok Build stores the plugin in its user-level plugin directory. The workflow's durable per-project checkpoints and activity logs are stored at `${GROK_HOME:-$HOME/.grok}/artifacts/auto-build-engine/<project-id>/`. The Grok home is configurable using `GROK_HOME`. The engine tracks up to five successive invocations per objective in `state.json`; `/build continue` uses the next run and resumes the saved phase. Host-imposed time, token, model, and permission limits still apply.

## Vercel scope

The package supports deployment only through an already-authenticated Vercel CLI that is already linked to the target project. It contains no Vercel connector, OAuth/OAuth2 setup, credential handling, or connection bootstrap. Live deployment runs only when the current project target and CLI are available and authorized. The skill records and verifies a deployment URL instead of claiming an unverified release.

## Autonomy and host limits

The workflow makes sensible reversible choices, inspects the project before acting, continues without routine interruptions, saves checkpoints, and resumes on `/build continue`. The requested “effort 100/Xhigh,” unlimited runtime, unlimited tokens, and access to all tools cannot be granted by a plugin manifest. The active model and Grok Build host control actual effort options, time, tokens, tool availability, authentication, sandboxing, and permission approvals. The plugin does not change these settings or bypass the host permission system.

## Included files

`grok-auto-build-engine/plugin.json` is the Grok plugin manifest. `skills/build/SKILL.md` is the full operational prompt and `/build` skill. `package.json` and `manifest.json` preserve the requested package metadata. `config/autonomy.json` stores workflow preferences only. `scripts/verify-environment.sh`, `scripts/bootstrap.sh`, and `scripts/execute-pipeline.sh` provide bounded local helpers. `src/core-engine.js` manages resumable state and the five-run counter. `docs/FORMAT-SOURCES.md` records the official Grok Build references used.
