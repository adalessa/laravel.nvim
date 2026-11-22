#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$root"

fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }

scripts/test.sh --list | grep -q 'tests/unit/api_response_spec.lua' \
  || fail "--list does not include unit specs"

scripts/test.sh --file tests/unit/api_response_spec.lua >/dev/null \
  || fail "--file did not pass"

if scripts/test.sh --filter does-not-exist >/dev/null 2>&1; then
  fail "--filter with no matches should exit non-zero"
fi

if [ ! -d tests/component ]; then
  scripts/test.sh --component | grep -q 'no component specs' \
    || fail "--component should report that no component specs exist yet"
fi

echo "runner tests OK"
