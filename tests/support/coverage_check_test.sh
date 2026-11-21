#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$root"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/empty-tests"

cat >"$tmp/missing.lua" <<'LUA'
return {
  { name = "broken", status = "covered", specs = { "tests/unit/nope_spec.lua" } },
}
LUA

if nvim -l scripts/coverage-check.lua \
  --manifest "$tmp/missing.lua" --tests-root "$tmp/empty-tests" >/dev/null 2>&1; then
  echo "FAIL: missing spec should fail" >&2
  exit 1
fi

cat >"$tmp/pending.lua" <<'LUA'
return {
  { name = "later", status = "pending", specs = {} },
}
LUA

nvim -l scripts/coverage-check.lua \
  --manifest "$tmp/pending.lua" --tests-root "$tmp/empty-tests" >/dev/null \
  || { echo "FAIL: pending should pass without --strict" >&2; exit 1; }

if nvim -l scripts/coverage-check.lua \
  --manifest "$tmp/pending.lua" --tests-root "$tmp/empty-tests" --strict >/dev/null 2>&1; then
  echo "FAIL: pending should fail with --strict" >&2
  exit 1
fi

nvim -l scripts/coverage-check.lua >/dev/null \
  || { echo "FAIL: real manifest should pass" >&2; exit 1; }

echo "coverage check tests OK"
