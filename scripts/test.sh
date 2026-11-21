#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

NVIM="${NVIM:-nvim}"

suites=()
explicit=()
file=""
filter=""
list_only=0

usage() {
  cat <<'USAGE'
Usage: scripts/test.sh [--unit] [--component] [--integration] [--all]
                       [--file <path>] [--filter <substring>] [--list]

With no suite flags, runs unit and component specs.
USAGE
}

add_suite() {
  local suite="$1"
  local existing
  for existing in "${suites[@]:-}"; do
    [ "$existing" = "$suite" ] && return
  done
  suites+=("$suite")
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --unit | --component | --integration)
      suite="${1#--}"
      add_suite "$suite"
      explicit+=("$suite")
      ;;
    --all)
      for suite in unit component integration; do
        add_suite "$suite"
        explicit+=("$suite")
      done
      ;;
    --file)
      [ "$#" -ge 2 ] || { echo "--file requires a path" >&2; exit 2; }
      file="$2"
      shift
      ;;
    --filter)
      [ "$#" -ge 2 ] || { echo "--filter requires a pattern" >&2; exit 2; }
      filter="$2"
      shift
      ;;
    --list)
      list_only=1
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if [ "${#suites[@]}" -eq 0 ] && [ -z "$file" ]; then
  add_suite unit
  add_suite component
fi

collect_specs() {
  local suite
  for suite in "${suites[@]}"; do
    local dir="tests/$suite"
    [ -d "$dir" ] || continue
    find "$dir" -type f -name '*_spec.lua' | sort
  done
}

if [ -n "$file" ]; then
  [ -f "$file" ] || { echo "spec not found: $file" >&2; exit 1; }
  specs="$file"
else
  if [ -n "$filter" ]; then
    specs="$(collect_specs | grep -F "$filter" || true)"
  else
    specs="$(collect_specs)"
  fi
fi

if [ -z "$specs" ] && [ -n "$filter" ]; then
  echo "no specs match filter: $filter" >&2
  exit 1
fi

if [ "$list_only" -eq 1 ]; then
  [ -z "$specs" ] || printf '%s\n' "$specs"
  exit 0
fi

for suite in "${explicit[@]:-}"; do
  [ -n "$suite" ] || continue
  if [ ! -d "tests/$suite" ]; then
    echo "no $suite specs yet"
  fi
done

if [ -n "$file" ]; then
  "$NVIM" --headless --noplugin -u tests/minimal_init.lua \
    -c "PlenaryBustedFile $file"
  exit $?
fi

if [ -n "$filter" ]; then
  while IFS= read -r spec; do
    [ -n "$spec" ] || continue
    "$NVIM" --headless --noplugin -u tests/minimal_init.lua \
      -c "PlenaryBustedFile $spec"
  done <<<"$specs"
  exit 0
fi

for suite in "${suites[@]}"; do
  dir="tests/$suite"
  [ -d "$dir" ] || continue
  "$NVIM" --headless --noplugin -u tests/minimal_init.lua \
    -c "PlenaryBustedDirectory $dir { minimal_init = 'tests/minimal_init.lua' }"
done
