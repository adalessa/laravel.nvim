# Test Infrastructure Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the laravel.nvim test suite reproducible and enforceable: a Nix devShell, a hermetic runner, a green baseline, lint and coverage checks, and a GitHub Actions pipeline.

**Architecture:** A `flake.nix` devShell pins Neovim, test plugins, tree-sitter parsers, pickers, PHP, and Lua tooling, and links plugins into `.tests/deps`. `tests/minimal_init.lua` resolves those dependencies explicitly and fails with an actionable message. `scripts/test.sh` and `Makefile` provide the single entry point used locally and in CI. CI runs fast, integration, coverage, and lint jobs with the same `make` targets.

**Tech Stack:** Nix flakes, Neovim >= 0.10, plenary/busted, nvim-nio, nvim-treesitter, stylua, luacheck, selene, GitHub Actions.

**Spec:** `docs/superpowers/specs/2026-11-21-test-infrastructure-design.md`

## Global Constraints

- Neovim floor is >= 0.10; CI initially targets Ubuntu only.
- `make test` = unit + component, hermetic, target under ~15 seconds.
- Fast tests must not use network, PHP, external binaries, real filesystem watchers, `$HOME`, or the developer's `stdpath('data')`.
- Integration tests may use temp files and flake-provided `rg`/`jq`; no network.
- Keep plenary/busted and `nio.tests`.
- Coverage is a curated feature-area manifest, not one spec per module.
- The coverage check is non-strict in CI until the roadmap is complete; `--strict` exists for later.
- Lint covers `lua/` and `tests/` and is blocking once the baseline is clean.
- Run every command from the repository root.
- Do not read or write the user's real Neovim configuration or Laravel projects.
- This plan covers the spec's phases 1-2 only. The coverage growth and helper
  work in phases 3-8 gets separate plans; the spec's roadmap is the source of
  truth for those.

## Review Focus

These are the failure modes most likely to bite a user of this infrastructure. Each is pinned by a test in the task that owns the code.

1. **Missing dependencies outside `nix develop`:** `make test` must print the missing plugins and the fix, not crash with a raw `module 'nio' not found`.
2. **Neovim without the PHP parser:** model completion must return no items and must not raise a nil-index error.
3. **Commands run from a subdirectory:** dependency and fixture paths resolve from the repository root, not `$PWD`.
4. **A new or renamed spec file is not listed in the coverage manifest:** the check fails with the unlisted path instead of silently ignoring it.
5. **Fresh CI machine with no cache or user config:** the required jobs build from `flake.lock` and pass without any preinstalled Neovim plugins, pinned by Task 1's clean-environment check.

## Preflight

Before Task 1:

- Change the spec status from `proposed` to `approved`.
- Commit both documents:

```bash
git add docs/superpowers/specs/2026-11-21-test-infrastructure-design.md \
        docs/superpowers/plans/2026-11-21-test-infrastructure-foundation.md
git commit -m "docs: add test infrastructure design and plan"
```

---

### Task 1: Nix devShell and environment check

**Files:**
- Create: `flake.nix`
- Create: `flake.lock` (generated)
- Create: `scripts/check-env.sh`
- Test: `scripts/check-env.sh` run from outside and inside the flake

**Interfaces:**
- Produces: `LARAVEL_TEST_DEPS` pointing to a directory containing
  `plenary.nvim`, `nvim-nio`, `nui.nvim`, `nvim-treesitter`, and the optional
  picker/completion plugins as symlinks.
- Produces: a devShell with `nvim`, `git`, `rg`, `jq`, `make`, `stylua`,
  `luacheck`, `selene`, `php`, and `composer`.

- [ ] **Step 1: Write the failing environment check**

Create `scripts/check-env.sh`:

```bash
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
```

- [ ] **Step 2: Run the check to verify it fails**

Run: `bash scripts/check-env.sh`
Expected: exit 1 with missing commands and/or `LARAVEL_TEST_DEPS`.

- [ ] **Step 3: Create `flake.nix`**

Use this structure; adjust only attribute names that differ in the pinned
nixpkgs. Verify parser files exist in Step 5 before proceeding.

```nix
{
  description = "laravel.nvim development and test environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [ p.php p.json ]);
        plugins = {
          "plenary.nvim" = pkgs.vimPlugins.plenary-nvim;
          "nvim-nio" = pkgs.vimPlugins.nvim-nio;
          "nui.nvim" = pkgs.vimPlugins.nui-nvim;
          "nvim-treesitter" = treesitter;
          "telescope.nvim" = pkgs.vimPlugins.telescope-nvim;
          "fzf-lua" = pkgs.vimPlugins.fzf-lua;
          "snacks.nvim" = pkgs.vimPlugins.snacks-nvim;
          "nvim-cmp" = pkgs.vimPlugins.nvim-cmp;
          "blink.cmp" = pkgs.vimPlugins.blink-cmp;
        };
        linkPlugins = pkgs.lib.concatStringsSep "\n" (
          pkgs.lib.mapAttrsToList
            (name: path: ''ln -sfn ${path} "$deps/${name}"'')
            plugins
        );
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            neovim
            git
            ripgrep
            jq
            gnumake
            stylua
            luacheck
            selene
            php
            composer
          ];

          shellHook = ''
            root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
            deps="$root/.tests/deps"
            mkdir -p "$deps"
            ${linkPlugins}
            export LARAVEL_TEST_DEPS="$deps"
            echo "laravel.nvim test deps: $LARAVEL_TEST_DEPS"
          '';
        };
      });
}
```

- [ ] **Step 4: Generate the lock file**

Run: `nix flake lock`
Expected: `flake.lock` created; no evaluation errors.

- [ ] **Step 5: Verify the devShell**

Run: `nix develop --command bash scripts/check-env.sh`
Expected: `Test environment OK`.

Run: `nix develop --command bash -c 'ls "$LARAVEL_TEST_DEPS/nvim-treesitter/parser" | grep -E "^(php|json)\\.so$"'`
Expected: both `php.so` and `json.so`.
If the parser directory is elsewhere, inspect the store path and adjust the
symlink or add a dedicated `LARAVEL_TS_PARSERS` variable; record the decision in
the spec if it changes the interface.

- [ ] **Step 6: Commit**

```bash
git add flake.nix flake.lock scripts/check-env.sh
git commit -m "feat: add nix devshell for test dependencies"
```

---

### Task 2: Explicit dependency resolution in test init

**Files:**
- Create: `tests/support/deps.lua`
- Create: `tests/unit/support/deps_spec.lua`
- Modify: `tests/minimal_init.lua`
- Test: `tests/unit/support/deps_spec.lua`

**Interfaces:**
- Produces: `M.resolve(opts) -> table<string, string>, string[]` where
  `opts = { env = table, repo_root = string, data_dir = string }`. The first
  return value maps plugin names to existing directories; the second lists
  missing required plugins.
- Produces: `M.setup(resolved)` appends plugin paths to `runtimepath` and
  sources `plugin/plenary.vim`.
- Required plugins: `plenary.nvim`, `nvim-nio`, `nui.nvim`,
  `nvim-treesitter`.

- [ ] **Step 1: Write the failing test**

Create `tests/unit/support/deps_spec.lua` with these cases:

```lua
local deps = dofile("tests/support/deps.lua")

describe("test dependency resolution", function()
  local root

  before_each(function()
    root = vim.fn.tempname()
    vim.fn.mkdir(root, "p")
  end)

  after_each(function()
    vim.fn.delete(root, "rf")
  end)

  local function plugin(base, name)
    vim.fn.mkdir(base .. "/" .. name, "p")
  end

  it("prefers LARAVEL_TEST_DEPS", function()
    local env_dir = root .. "/env"
    local repo_dir = root .. "/repo/.tests/deps"
    for _, name in ipairs({ "plenary.nvim", "nvim-nio", "nui.nvim", "nvim-treesitter" }) do
      plugin(env_dir, name)
      plugin(repo_dir, name)
    end

    local resolved, missing = deps.resolve({
      env = { LARAVEL_TEST_DEPS = env_dir },
      repo_root = root .. "/repo",
      data_dir = root .. "/data/lazy",
    })

    assert.equals(env_dir .. "/plenary.nvim", resolved["plenary.nvim"])
    assert.same({}, missing)
  end)

  it("falls back to .tests/deps", function()
    local repo_dir = root .. "/repo/.tests/deps"
    for _, name in ipairs({ "plenary.nvim", "nvim-nio", "nui.nvim", "nvim-treesitter" }) do
      plugin(repo_dir, name)
    end

    local resolved, missing = deps.resolve({
      env = {},
      repo_root = root .. "/repo",
      data_dir = root .. "/data/lazy",
    })

    assert.equals(repo_dir .. "/nui.nvim", resolved["nui.nvim"])
    assert.same({}, missing)
  end)

  it("falls back to the lazy stdpath", function()
    local data_dir = root .. "/data/lazy"
    for _, name in ipairs({ "plenary.nvim", "nvim-nio", "nui.nvim", "nvim-treesitter" }) do
      plugin(data_dir, name)
    end

    local resolved, missing = deps.resolve({
      env = {},
      repo_root = root .. "/repo",
      data_dir = data_dir,
    })

    assert.equals(data_dir .. "/nvim-nio", resolved["nvim-nio"])
    assert.same({}, missing)
  end)

  it("reports missing plugins instead of silently continuing", function()
    local _, missing = deps.resolve({
      env = {},
      repo_root = root .. "/repo",
      data_dir = root .. "/data/lazy",
    })

    assert.same({ "plenary.nvim", "nvim-nio", "nui.nvim", "nvim-treesitter" }, missing)
  end)

  it("does not depend on the current working directory", function()
    local repo = root .. "/repo"
    local repo_dir = repo .. "/.tests/deps"
    for _, name in ipairs({ "plenary.nvim", "nvim-nio", "nui.nvim", "nvim-treesitter" }) do
      plugin(repo_dir, name)
    end
    local original = vim.fn.getcwd()
    vim.cmd("cd " .. vim.fn.fnameescape(root))

    local resolved = deps.resolve({
      env = {},
      repo_root = repo,
      data_dir = root .. "/data/lazy",
    })
    vim.cmd("cd " .. vim.fn.fnameescape(original))

    assert.equals(repo_dir .. "/plenary.nvim", resolved["plenary.nvim"])
  end)
end)
```

- [ ] **Step 2: Run the test to verify it fails**

Run (inside `nix develop`):
```bash
nvim --headless --noplugin \
  --cmd "set rtp^=$LARAVEL_TEST_DEPS/plenary.nvim,$LARAVEL_TEST_DEPS/nvim-nio,$LARAVEL_TEST_DEPS/nui.nvim,$PWD" \
  -c "runtime plugin/plenary.vim" \
  -c "PlenaryBustedFile tests/unit/support/deps_spec.lua"
```
Expected: FAIL because `tests/support/deps.lua` does not exist.

- [ ] **Step 3: Implement `tests/support/deps.lua`**

Required names are checked in a stable order:
`{ "plenary.nvim", "nvim-nio", "nui.nvim", "nvim-treesitter" }`.

Resolution rules:
1. If `$LARAVEL_TEST_DEPS` is set and is a directory, use it as the only root.
2. Otherwise use `<repo_root>/.tests/deps` if it is a directory.
3. Otherwise use `<data_dir>` if it is a directory.
4. If no root exists, every required name is missing.
5. For the chosen root, return `resolved[name] = root .. "/" .. name` for
   every name whose directory exists, and collect the rest in `missing` in
   required-name order.
6. Optional plugins (pickers, completion) are added to `resolved` when
   present, but never appear in `missing`.

`M.setup(resolved)` iterates `resolved` in stable name order, calls
`vim.opt.rtp:append(path)`, then `vim.cmd("runtime! plugin/plenary.vim")`.

- [ ] **Step 4: Rewrite `tests/minimal_init.lua`**

Set `vim.notify = print`. Compute the repo root with
`vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")`.
`dofile(root .. "/tests/support/deps.lua")`, call `resolve` with
`vim.fn.stdpath("data") .. "/lazy"`, and if `missing` is non-empty raise:

```lua
error(table.concat({
  "Missing test dependencies: " .. table.concat(missing, ", "),
  "Run `nix develop` from the repository root (or `make deps` for a non-Nix setup).",
}, "\n"))
```

Call `deps.setup(resolved)`. Keep the existing `A`, `LoadStub`, and
`CreateApiMock` globals unchanged for compatibility.

- [ ] **Step 5: Run the test to verify it passes**

Run the same `PlenaryBustedFile` command from Step 2.
Expected: 5 successes, 0 failures.

- [ ] **Step 6: Verify the init fails cleanly without dependencies**

Run from a temporary copy so the repository's `.tests/deps` cannot be found:

```bash
tmp="$(mktemp -d)"
mkdir -p "$tmp/tests/support" "$tmp/home"
cp tests/minimal_init.lua "$tmp/tests/"
cp tests/support/deps.lua "$tmp/tests/support/"
env -u LARAVEL_TEST_DEPS HOME="$tmp/home" \
  nvim --headless -u "$tmp/tests/minimal_init.lua" -c q
```

Expected: an error listing the missing plugins and the `nix develop`/`make deps`
fix, not a raw `module not found`.

- [ ] **Step 7: Commit**

```bash
git add tests/support/deps.lua tests/unit/support/deps_spec.lua tests/minimal_init.lua
git commit -m "test: resolve test dependencies explicitly"
```

---

### Task 3: Test runner, Makefile, and non-Nix fallback

**Files:**
- Create: `scripts/test.sh`
- Create: `Makefile`
- Create: `tests/support/runner_test.sh`
- Test: `tests/support/runner_test.sh`

**Interfaces:**
- Produces: `scripts/test.sh` flags `--unit`, `--component`, `--integration`,
  `--all`, `--file <path>`, `--filter <substring>`, `--list`.
- Honors `NVIM` (default `nvim`) and `LARAVEL_TEST_DEPS`.
- Produces Make targets: `test`, `test-integration`, `test-all`, `test-file`,
  `deps`, `lint`, `format`, `coverage-check`, `ci`, `test-scripts`.

- [ ] **Step 1: Write the failing runner test**

Create `tests/support/runner_test.sh`:

```bash
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

scripts/test.sh --component | grep -q 'no component specs' \
  || fail "--component should report that no component specs exist yet"

echo "runner tests OK"
```

- [ ] **Step 2: Run it to verify it fails**

Run: `bash tests/support/runner_test.sh`
Expected: FAIL because `scripts/test.sh` does not exist.

- [ ] **Step 3: Implement `scripts/test.sh`**

Behavior:
- `ROOT` is the parent of `scripts/`; `cd "$ROOT"` before every run.
- `NVIM="${NVIM:-nvim}"`.
- `--list` prints matching spec paths sorted, without invoking Neovim.
- No suite flags means unit + component.
- `--all` means unit + component + integration.
- Missing suite directories are skipped; explicitly requesting one
  (`--component` or `--integration`) with no directory prints
  `no <suite> specs yet` and exits 0.
- If `--filter` matches nothing, print the pattern and exit 1.
- Run unit/component/integration with:
  ```bash
  "$NVIM" --headless --noplugin -u tests/minimal_init.lua \
    -c "PlenaryBustedDirectory <dir> { minimal_init = 'tests/minimal_init.lua' }"
  ```
- Run a single spec with:
  ```bash
  "$NVIM" --headless --noplugin -u tests/minimal_init.lua \
    -c "PlenaryBustedFile <file>"
  ```
- Stop on the first failing suite and propagate Neovim's exit code.

- [ ] **Step 4: Implement `tests/support/runner_test.sh` expectations**

Re-run: `bash tests/support/runner_test.sh`
Expected: `runner tests OK`.

- [ ] **Step 5: Create the Makefile**

Targets:

```make
NVIM ?= nvim
SHELL := /usr/bin/env bash

.PHONY: test test-integration test-all test-file test-scripts deps lint format coverage-check ci

test:
	scripts/test.sh --unit --component

test-integration:
	scripts/test.sh --integration

test-all:
	scripts/test.sh --all

test-file:
	scripts/test.sh --file $(FILE)

test-scripts:
	bash tests/support/runner_test.sh

deps:
	scripts/deps.sh

lint:
	stylua --check lua tests
	luacheck lua tests
	selene lua tests

format:
	stylua lua tests

coverage-check:
	nvim -l scripts/coverage-check.lua

ci: lint test-scripts test coverage-check
```

`make deps` invokes `scripts/deps.sh` (create it in Step 6). `scripts/test.sh`
must use `$NVIM`; the Makefile only sets a default.

- [ ] **Step 6: Implement the non-Nix fallback**

Create `scripts/deps.sh`:
- If `$LARAVEL_TEST_DEPS` is a non-empty directory containing the four
  required plugins, print the path and exit 0.
- Else create `.tests/deps` and clone:
  - `https://github.com/nvim-lua/plenary.nvim` (default branch)
  - `https://github.com/nvim-neotest/nvim-nio` tag `v1.10.1`
  - `https://github.com/MunifTanjim/nui.nvim` tag `v0.4.0`
  - `https://github.com/nvim-treesitter/nvim-treesitter` (default branch)
- Use `git clone --depth 1`, adding `--branch <tag>` where a tag is pinned.
- Export nothing; print:
  `export LARAVEL_TEST_DEPS="$PWD/.tests/deps"` and note that PHP/JSON
  parsers still require `nix develop` for the full integration suite.

- [ ] **Step 7: Verify both paths**

Run: `nix develop --command bash tests/support/runner_test.sh`
Expected: `runner tests OK`.

Run: `nix develop --command make test-file FILE=tests/unit/api_response_spec.lua`
Expected: 2 successes, 0 failures.

- [ ] **Step 8: Commit**

```bash
git add scripts/test.sh scripts/deps.sh Makefile tests/support/runner_test.sh
git commit -m "test: add runner and make entry points"
```

---

### Task 4: Parser guard and green baseline

**Files:**
- Modify: `lua/laravel/extensions/completion/model_completion_type_resolver.lua:122-126, 280-282`
- Create: `tests/unit/completion/parser_guard_spec.lua`
- Test: `tests/unit/completion/parser_guard_spec.lua` and the existing completion spec

**Interfaces:**
- `resolve_model_at_cursor(bufnr, cursor_before_line)` returns `nil` when the
  PHP parser is unavailable; it does not raise.
- `resolve_by_ts(bufnr, before)` returns `nil` under the same condition.

- [ ] **Step 1: Write the failing test**

Create `tests/unit/completion/parser_guard_spec.lua`:

```lua
local resolver = require("laravel.extensions.completion.model_completion_type_resolver")

describe("model completion parser guard", function()
  it("returns nil when the php parser is unavailable", function()
    local original = vim.treesitter.get_parser
    vim.treesitter.get_parser = function()
      return nil
    end

    local ok, result = pcall(resolver.resolve_model_at_cursor, 0, "")

    vim.treesitter.get_parser = original
    assert.is_true(ok)
    assert.is_nil(result)
  end)
end)
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `nix develop --command make test-file FILE=tests/unit/completion/parser_guard_spec.lua`
Expected: FAIL because the current code indexes a nil parser.

- [ ] **Step 3: Add the guards**

At the top of `resolve_model_at_cursor`:

```lua
local parser = vim.treesitter.get_parser(bufnr, "php")
if not parser then
  return nil
end
parser:parse()
```

In `resolve_by_ts`, do the same check before parsing. Do not change the
success-path behavior or the return shape.

- [ ] **Step 4: Run the guard test and the existing completion spec**

Run:
```bash
nix develop --command make test-file FILE=tests/unit/completion/parser_guard_spec.lua
nix develop --command make test-file FILE=tests/unit/completion/model_completion_identification_spec.lua
```
Expected: 1 success and 12 successes respectively, 0 failures.

- [ ] **Step 5: Run the full baseline**

Run: `nix develop --command make test-all`
Expected: 47 successes, 0 failures (the previous 29 + 12 completion + 5 dependency-resolution + 1 guard).

- [ ] **Step 6: Commit**

```bash
git add lua/laravel/extensions/completion/model_completion_type_resolver.lua tests/unit/completion/parser_guard_spec.lua
git commit -m "fix: guard model completion when the php parser is missing"
```

---

### Task 5: Lint baseline

**Files:**
- Modify: `.luacheckrc`
- Modify: `vim.toml`
- Modify: repository Lua formatting (mechanical, via `make format`)
- Test: `make lint`

**Interfaces:**
- `make lint` runs `stylua --check lua tests`, `luacheck lua tests`, and
  `selene lua tests`.
- `make format` runs `stylua lua tests`.

- [ ] **Step 1: Extend the linters for test globals**

Add to `.luacheckrc` globals:

```lua
"describe", "it", "before_each", "after_each", "assert",
"A", "LoadStub", "CreateApiMock",
```

Add to `vim.toml`:

```toml
[[A.args]]
type = "any"

[[LoadStub.args]]
type = "string"

[[CreateApiMock.args]]
type = "any"
[[CreateApiMock.args]]
type = "any"
```

If Selene rejects a declaration, mirror the existing `assert.*` style exactly
rather than disabling the lint.

- [ ] **Step 2: Run lint to see the baseline**

Run: `nix develop --command make lint`
Expected: FAIL, with formatting and/or warning output. Record which linter
failed; do not add broad ignores.

- [ ] **Step 3: Apply formatting and fix real warnings**

Run: `nix develop --command make format`
Re-run `make lint`. Fix unused variables, shadowing, and undefined globals in
place. Only add a targeted ignore when the warning is a known false positive,
and put the reason in a comment.

- [ ] **Step 4: Verify lint passes**

Run: `nix develop --command make lint`
Expected: exit 0.

- [ ] **Step 5: Commit**

```bash
git add .luacheckrc vim.toml lua tests
git commit -m "chore: establish lint baseline"
```

---

### Task 6: Feature-area coverage manifest and check

**Files:**
- Create: `tests/coverage_manifest.lua`
- Create: `scripts/coverage-check.lua`
- Create: `tests/support/coverage_check_test.sh`
- Test: `tests/support/coverage_check_test.sh` and `make coverage-check`

**Interfaces:**
- Manifest entry: `{ name = string, status = "covered" | "pending", specs = string[] }`.
- Checker flags: `--manifest <path>` (default `tests/coverage_manifest.lua`),
  `--tests-root <path>` (default `tests`), `--strict`.
- Exit 0 when all listed specs exist and all spec files are listed; exit 1
  otherwise. `--strict` also exits 1 when any area is `pending`.
- Prints a summary line: `coverage-check: N covered, M pending`.

- [ ] **Step 1: Write the failing checker test**

Create `tests/support/coverage_check_test.sh`:

```bash
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
```

- [ ] **Step 2: Run it to verify it fails**

Run: `nix develop --command bash tests/support/coverage_check_test.sh`
Expected: FAIL because the checker and manifest do not exist.

- [ ] **Step 3: Create the manifest**

Cover the existing specs and list the roadmap areas as pending. Start with:

- Covered: `dto`, `cache`, `utils`, `services`, `loaders`, `completion`,
  `test-tooling` (the dependency-resolution spec).
- Pending: `bootstrap`, `container-factory`, `options-env`, `events`,
  `core-services`, `commands`, `extensions-completion`, `model-info`,
  `route-info`, `diagnostics`, `composer-info`, `tinker`, `command-center`,
  `artisan-hub`, `pickers`, `health`, `e2e`.

Every spec in `tests/unit` must appear in at least one covered entry. Do not
mark an area covered without a spec.

- [ ] **Step 4: Implement `scripts/coverage-check.lua`**

Use `arg` for flags. Load the manifest with `dofile`. Collect spec files under
`--tests-root` with `vim.fs.find` matching `_spec%.lua$`. Validate:
- Every listed spec is readable.
- Every discovered spec is listed at least once.
- No entry is `covered` with an empty `specs` list.
- `pending` entries must have an empty `specs` list.
Print the summary; `os.exit(1)` on errors or strict pending, `os.exit(0)`
otherwise.

- [ ] **Step 5: Run the checker test and the real check**

Run: `nix develop --command bash tests/support/coverage_check_test.sh`
Expected: `coverage check tests OK`.

Run: `nix develop --command make coverage-check`
Expected: exit 0 with a summary showing covered and pending counts.

- [ ] **Step 6: Commit**

```bash
git add tests/coverage_manifest.lua scripts/coverage-check.lua tests/support/coverage_check_test.sh
git commit -m "test: add feature-area coverage manifest"
```

---

### Task 7: GitHub Actions and agent documentation

**Files:**
- Create: `.github/workflows/test.yml`
- Create: `AGENTS.md`
- Create: `docs/testing.md`
- Test: `make ci` locally; workflow YAML review

**Interfaces:**
- Required jobs: `fast`, `integration`, `coverage`, `lint`.
- Non-blocking job: `compat` for Neovim 0.10.x and nightly.
- All jobs use `nix develop --command make ...`; no test logic lives only in
  YAML.

- [ ] **Step 1: Write the workflow**

Create `.github/workflows/test.yml` with:
- `on: pull_request`, `on: push` to `main` and `development`,
  `workflow_dispatch`.
- `fast`: checkout, install Nix, `nix develop --command make test-scripts test`.
- `integration`: same, `make test-integration`.
- `coverage`: same, `make coverage-check`.
- `lint`: same, `make lint`.
- `compat`: `continue-on-error: true`, matrix `v0.10.4` and `nightly`,
  `rhysd/action-setup-vim@v1` to install Neovim, then capture the absolute
  binary path and run
  `nix develop --command env NVIM="$NVIM_BIN" make test`.
- `timeout-minutes: 15` on each job.
- Cache the Nix store with `nix-community/cache-nix-action`, keyed on
  `flake.lock`; if that action is unavailable, omit caching rather than block
  the pipeline.
- Pin actions to released majors. If a chosen action version is unavailable,
  use the current release and note it in the PR; do not leave floating `main`.

- [ ] **Step 2: Write `AGENTS.md`**

Include, concisely:
- The quickstart: `nix develop`, then `make test`, `make test-integration`,
  `make test-all`.
- Layer map: `tests/unit`, `tests/component`, `tests/integration`; what belongs
  where.
- Rules: write the failing test first for new behavior; add a regression test
  for every bug fix; keep fast tests hermetic; no `$HOME` or personal Laravel
  projects; run the targeted spec first.
- Links to the spec, this plan, `docs/testing.md`, and the coverage manifest.
- Current helpers: `A`, `LoadStub`, `CreateApiMock`; note that `fake_api`,
  `fake_process`, `fake_watcher`, `temp_project`, and `with_test_app` arrive
  with the coverage phases.

- [ ] **Step 3: Write `docs/testing.md`**

Include:
- The test pyramid and directory map.
- Command reference with expected runtimes.
- A recipe for a loader/component test using `CreateApiMock` and `LoadStub`.
- A recipe for a buffer/UI integration test using a temporary buffer (copy the
  `with_buffer` pattern from the completion spec).
- A recipe for an async test using `nio.tests`.
- How to add a feature area to the manifest.
- The ambient-effects policy from the spec.

- [ ] **Step 4: Run the full local CI equivalent**

Run: `nix develop --command make ci`
Expected: lint, runner tests, fast suite, and coverage check all pass.

Run: `nix develop --command make test-all`
Expected: 47 successes, 0 failures.

- [ ] **Step 5: Sanity-check the workflow**

Run: `git diff --check`
Expected: no whitespace errors.
Manually confirm every job has `runs-on`, `timeout-minutes`, a checkout step,
and a Nix install step; confirm `compat` has `continue-on-error: true`.

- [ ] **Step 6: Commit**

```bash
git add .github/workflows/test.yml AGENTS.md docs/testing.md
git commit -m "ci: add test pipeline and agent testing guide"
```

---

### Task 8: Final verification

**Files:** none new; verification and any fixups.

- [ ] **Step 1: Verify the clean-clone path**

Run:
```bash
nix develop --command bash scripts/check-env.sh
nix develop --command make ci
nix develop --command make test-all
```
Expected: environment OK; all commands exit 0; 47 successes.

- [ ] **Step 2: Verify the missing-dependency failure**

Use a temporary copy, as in Task 2 Step 6, so `.tests/deps` is not found:

```bash
tmp="$(mktemp -d)"
mkdir -p "$tmp/tests/support" "$tmp/home"
cp tests/minimal_init.lua "$tmp/tests/"
cp tests/support/deps.lua "$tmp/tests/support/"
env -u LARAVEL_TEST_DEPS HOME="$tmp/home" \
  nvim --headless -u "$tmp/tests/minimal_init.lua" -c q
```

Expected: actionable missing-plugin message, non-zero exit.

- [ ] **Step 3: Review the changes**

Run: `git status --short` and `git log --oneline -10`
Expected: only intended files; one commit per task; no generated `.tests/` or
editor files staged.

- [ ] **Step 4: Report**

Report the commands run, the final pass count, and any deviations from the
plan. Do not claim CI is green until the workflow has run on GitHub; local
`make ci` is the available evidence.
