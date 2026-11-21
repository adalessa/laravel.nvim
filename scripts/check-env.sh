#!/usr/bin/env bash
set -euo pipefail

missing=()
for cmd in nvim git rg jq make stylua luacheck selene php composer; do
  command -v "$cmd" >/dev/null 2>&1 || missing+=("command:$cmd")
done

deps="${LARAVEL_TEST_DEPS:-}"
if [ -z "$deps" ] || [ ! -d "$deps" ]; then
  missing+=("LARAVEL_TEST_DEPS")
else
  for plugin in plenary.nvim nvim-nio nui.nvim nvim-treesitter; do
    [ -e "$deps/$plugin" ] || missing+=("plugin:$plugin")
  done
fi

if [ "${#missing[@]}" -gt 0 ]; then
  printf 'Missing test environment requirements:\n' >&2
  printf '  - %s\n' "${missing[@]}" >&2
  printf 'Run `nix develop` (or `make deps`) from the repository root.\n' >&2
  exit 1
fi

nvim --headless -u NONE \
  -c 'lua assert(vim.fn.has("nvim-0.10") == 1, "Neovim >= 0.10 required")' \
  -c q
echo "Test environment OK"
