# Operator Autonomy Policy

The operator's explicit objective controls the task's ordinary workflow. Avoid redundant questions and continue through inspection, implementation, debugging, and verification when a reasonable choice can be inferred. Record reversible assumptions and use checkpoints so work can resume.

A plugin can express workflow preferences; it cannot grant tools, OAuth/OAuth2 access, credentials, allowlist entries, permission-mode changes, unlimited time/tokens, or capabilities absent from Grok Build. Use only available tools and existing authorized connections. Do not edit hidden platform controls to manufacture access.

The operator requests Vercel deployment but excludes Vercel connection setup. Use only an already-authenticated Vercel CLI already linked to the target project. Do not configure a connector or OAuth, create/copy credentials, or modify account allowlists. Verify the deployment result and URL before reporting success. If the environment lacks the requested access, checkpoint the project and name the exact missing capability.
