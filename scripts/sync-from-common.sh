#!/usr/bin/env bash
set -euo pipefail
# Pull latest hhbp-common.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

git -C "$REPO_ROOT/common" pull origin main
git -C "$REPO_ROOT" add common
git -C "$REPO_ROOT" commit -m "chore: sync from hhbp-common"
