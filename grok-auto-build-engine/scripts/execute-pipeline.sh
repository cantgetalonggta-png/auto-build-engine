#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || ! -d "$1" ]]; then
  echo "Usage: $0 <project-directory>" >&2
  exit 2
fi
PROJECT="$(cd "$1" && pwd -P)"
if [[ ! -f "$PROJECT/package.json" ]]; then
  echo "No package.json at $PROJECT. Select project-specific commands through the /build workflow." >&2
  exit 3
fi
if ! command -v node >/dev/null 2>&1; then
  echo "Node.js is required to inspect package.json." >&2
  exit 127
fi

cd "$PROJECT"
SCRIPTS_JSON="$(node -e 'const p=require(process.argv[1]); process.stdout.write(JSON.stringify(p.scripts||{}))' "$PROJECT/package.json")"
if [[ -f pnpm-lock.yaml ]]; then
  PM=pnpm
elif [[ -f yarn.lock ]]; then
  PM=yarn
elif [[ -f bun.lockb || -f bun.lock ]]; then
  PM=bun
else
  PM=npm
fi

if ! command -v "$PM" >/dev/null 2>&1; then
  echo "The project lockfile selects '$PM', but that executable is unavailable." >&2
  exit 127
fi

if [[ ! -d node_modules ]]; then
  case "$PM" in
    npm)
      if [[ -f package-lock.json ]]; then npm ci; else echo "No package-lock.json; dependency installation skipped."; fi
      ;;
    pnpm) pnpm install --frozen-lockfile ;;
    yarn) yarn install --frozen-lockfile ;;
    bun) bun install --frozen-lockfile ;;
  esac
fi

has_script() {
  node -e 'const s=JSON.parse(process.argv[1]); process.exit(Object.prototype.hasOwnProperty.call(s, process.argv[2]) ? 0 : 1)' "$SCRIPTS_JSON" "$1"
}
run_script() {
  local name="$1"
  case "$PM" in
    npm) npm run "$name" ;;
    pnpm) pnpm run "$name" ;;
    yarn) yarn run "$name" ;;
    bun) bun run "$name" ;;
  esac
}

ran=0
for script in build test lint; do
  if has_script "$script"; then
    echo "[PIPELINE] Running $PM $script"
    run_script "$script"
    ran=1
  fi
done
if [[ "$ran" -eq 0 ]]; then
  echo "No build, test, or lint scripts are defined. The /build workflow must select project-specific verification." >&2
  exit 4
fi
printf '\nPipeline completed successfully for %s\n' "$PROJECT"
