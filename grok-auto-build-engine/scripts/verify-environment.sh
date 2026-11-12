#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="${1:-$PWD}"
if [[ ! -d "$WORKSPACE" ]]; then
  echo "Workspace does not exist: $WORKSPACE" >&2
  exit 2
fi
WORKSPACE="$(cd "$WORKSPACE" && pwd -P)"
printf 'Workspace: %s\n' "$WORKSPACE"
printf 'OS: %s\n' "$(uname -s 2>/dev/null || echo unknown)"
printf 'Architecture: %s\n' "$(uname -m 2>/dev/null || echo unknown)"

for tool in git node npm pnpm yarn bun python3 uv pytest vercel; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf '%-10s %s\n' "$tool" "$(command -v "$tool")"
  else
    printf '%-10s %s\n' "$tool" "not found"
  fi
done

if [[ -f "$WORKSPACE/package.json" ]] && command -v node >/dev/null 2>&1; then
  node - "$WORKSPACE/package.json" <<'NODE'
const fs = require('node:fs');
const file = process.argv[2];
try {
  const pkg = JSON.parse(fs.readFileSync(file, 'utf8'));
  console.log('Node package:', pkg.name || '(unnamed)');
  console.log('Available npm scripts:', Object.keys(pkg.scripts || {}).join(', ') || '(none)');
} catch (error) {
  console.error(`Could not parse package.json: ${error.message}`);
  process.exitCode = 1;
}
NODE
fi

printf '\nThis report lists detected executables only. It does not verify credentials, make network requests, change environment variables, or grant permissions.\n'
