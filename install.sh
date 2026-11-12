#!/usr/bin/env bash
set -euo pipefail

PACKAGE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$PACKAGE_ROOT/grok-auto-build-engine"
PLUGIN_NAME="grok-auto-build-engine"
GROK_HOME="${GROK_HOME:-$HOME/.grok}"

if ! command -v grok >/dev/null 2>&1; then
  echo "Grok Build CLI ('grok') was not found. Install Grok Build, then rerun this installer." >&2
  exit 127
fi
if [[ ! -f "$PLUGIN_DIR/plugin.json" || ! -f "$PLUGIN_DIR/skills/build/SKILL.md" ]]; then
  echo "Plugin package is incomplete: $PLUGIN_DIR" >&2
  exit 2
fi

mkdir -p "$GROK_HOME/artifacts/auto-build-engine"
node "$PLUGIN_DIR/src/core-engine.js" self-test

echo "Validating Grok plugin..."
grok plugin validate "$PLUGIN_DIR"

echo "Installing at user scope with explicit trust for this local package..."
grok plugin install "$PLUGIN_DIR" --trust
grok plugin enable "$PLUGIN_NAME"

echo
echo "Installed. Use /build <objective> to begin or /build continue to resume."
echo "Persistent checkpoint directory: $GROK_HOME/artifacts/auto-build-engine/"
echo "No project dependencies were installed and no project pipeline was run during installation."
