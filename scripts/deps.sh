#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="$ROOT/.tests/deps"
REQUIRED=(plenary.nvim nvim-nio nui.nvim nvim-treesitter)

valid() {
  local dir="$1"
  local plugin
  [ -d "$dir" ] || return 1
  for plugin in "${REQUIRED[@]}"; do
    [ -d "$dir/$plugin" ] || return 1
  done
}

if [ -n "${LARAVEL_TEST_DEPS:-}" ] && valid "$LARAVEL_TEST_DEPS"; then
  echo "$LARAVEL_TEST_DEPS"
  exit 0
fi

mkdir -p "$TARGET"

clone() {
  local name="$1"
  local url="$2"
  local tag="${3:-}"
  if [ -d "$TARGET/$name" ]; then
    return
  fi
  if [ -n "$tag" ]; then
    git clone --depth 1 --branch "$tag" "$url" "$TARGET/$name"
  else
    git clone --depth 1 "$url" "$TARGET/$name"
  fi
}

clone plenary.nvim https://github.com/nvim-lua/plenary.nvim
clone nvim-nio https://github.com/nvim-neotest/nvim-nio v1.10.1
clone nui.nvim https://github.com/MunifTanjim/nui.nvim 0.4.0
clone nvim-treesitter https://github.com/nvim-treesitter/nvim-treesitter

valid "$TARGET" || {
  echo "dependency bootstrap failed; missing one of: ${REQUIRED[*]}" >&2
  exit 1
}

echo "export LARAVEL_TEST_DEPS=\"$TARGET\""
echo "note: PHP/JSON parsers require nix develop for parser-dependent specs."
