#!/bin/bash
# ===========================================================================
# Script:      install-hooks.sh
# Version:     1.0.0
# Author:      Ladislav Osvald
# Updated:     2026-07-26
#
# Description:
#   Installs this repo's git hooks from tools/hooks/ into .git/hooks/.
#   Hooks are NOT carried by a clone (.git/hooks is local), so the source of
#   truth lives in tools/hooks/ — versioned, reviewable, backed up — and this
#   script copies it into place. Run it after a fresh clone or a machine
#   rebuild. Idempotent: safe to run repeatedly.
#
#   Installed hooks:
#     pre-commit  — refuses a direct commit on main (merges pass)
#     pre-push    — refuses a non-fast-forward push to the public remote
#
# Usage: bash tools/install-hooks.sh
# ===========================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC_DIR="$SCRIPT_DIR/hooks"
HOOK_DIR="$REPO_ROOT/.git/hooks"

[[ -d "$REPO_ROOT/.git" ]] || { echo "ERROR: $REPO_ROOT is not a git repo." >&2; exit 1; }
[[ -d "$SRC_DIR" ]]       || { echo "ERROR: $SRC_DIR not found." >&2; exit 1; }

mkdir -p "$HOOK_DIR"

installed=0
for src in "$SRC_DIR"/*; do
    [[ -f "$src" ]] || continue
    name="$(basename "$src")"
    cp "$src" "$HOOK_DIR/$name"
    chmod +x "$HOOK_DIR/$name"
    echo "  installed: $name"
    installed=$((installed + 1))
done

echo ""
echo "$installed hook(s) installed into .git/hooks/."
echo "Verify: git commit on main must be refused; a merge into main must pass."
