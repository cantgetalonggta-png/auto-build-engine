#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE="${1:-$PWD}"

"$SCRIPT_DIR/verify-environment.sh" "$WORKSPACE"
node "$PLUGIN_ROOT/src/core-engine.js" init "$WORKSPACE"
printf '\nBootstrap complete. No dependencies were installed and no project build/test/deploy command was run.\n'
printf 'Use /build <objective> to start implementation, or /build continue to resume a saved checkpoint.\n'
