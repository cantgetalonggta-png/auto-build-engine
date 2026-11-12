# Install notes

Run the package-root `install.sh` on the system where Grok Build is installed. The script validates the plugin, installs it using the Grok CLI at user scope, enables it, and creates the checkpoint directory under `${GROK_HOME:-$HOME/.grok}/artifacts/auto-build-engine/`.

Installation does not automatically execute project build scripts. Use `/build <objective>` to start an explicitly requested project task. Use `/build continue` to resume saved state. The helper pipeline is available at `scripts/execute-pipeline.sh <project-directory>` and returns a nonzero exit status if a configured build, test, or lint script fails.
