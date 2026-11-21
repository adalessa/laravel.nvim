# Testing Guide

The suite is organized as a pyramid. Most behavior is proven at the lowest
layer that can prove it, and every layer has a clear boundary.

| Layer | Directory | Proves |
| --- | --- | --- |
| Unit | `tests/unit` | Pure Lua and Neovim-independent logic: utils, DTOs, mappers, options, container/factory |
| Component | `tests/component` | Services, loaders, commands, events, and watcher consumers with fakes |
| Integration | `tests/integration` | Real headless Neovim buffers, windows, extmarks, tree-sitter, and provider boot |

`tests/support` contains setup, shared shell checks, and the dependency
resolver. `tests/stubs` contains immutable JSON fixtures; planned project
skeletons will live under `tests/fixtures`.

## Commands

Run everything from the repository root inside `nix develop`.

| Command | Use | Target |
| --- | --- | --- |
| `make test` | Default fast loop: unit + component | under ~15s |
| `make test-integration` | Headless Neovim behavior | under ~60s |
| `make test-all` | Everything | under ~60s |
| `make test-file FILE=<path>` | One spec while iterating | seconds |
| `make test-scripts` | Runner and coverage-check meta-tests | seconds |
| `make lint` | stylua, luacheck, selene | seconds |
| `make format` | Apply stylua | seconds |
| `make coverage-check` | Validate the feature manifest | instant |
| `make ci` | lint + script checks + fast suite + coverage | under ~1 min |
| `make deps` | Clone test plugins for non-Nix setups | first run |

The runner honors `NVIM` (for example `NVIM=/path/to/nvim make test`) and
`LARAVEL_TEST_DEPS`. `make deps` cannot build PHP/JSON tree-sitter parsers; use
`nix develop` for parser-dependent specs, which currently live in
`tests/unit/completion`.

## Adding a Unit or Component Test

1. Create `tests/unit/<area>/<behavior>_spec.lua` (or
   `tests/component/<area>/...`).
2. Write one behavior with a clear name.
3. Run `make test-file FILE=<path>` and watch it fail for the expected reason.
4. Implement the minimal behavior change.
5. Run the targeted spec, then `make test`.
6. Add the spec path to `tests/coverage_manifest.lua`; every spec file must be
   listed in the matching entry (create a new entry for a new area).

A loader/component test with the existing helpers:

```lua
local nio = require("nio")
local a = nio.tests
local ApiResponse = require("laravel.dto.api_response")

describe("example loader", function()
  a.it("loads from the json stub", function()
    local api = CreateApiMock(function(command)
      assert.equals("artisan route:list --json", command)
    end, ApiResponse:new({ LoadStub("./tests/stubs/routes_list.json") }, 0, {}))

    local loader = require("laravel.loaders.routes_loader"):new(api)
    loader.api = api
    loader.options = { get = function(_, default) return default end }
    loader.mapper = require("laravel.mappers.route_mapper")
    loader.watcher = { register = function() end }

    local items, err = loader:load()
    assert.is_nil(err)
    assert.is_table(items)
  end)
end)
```

`LoadStub` reads through `nio`, so use `nio.tests` (`a.it`) for any spec that
calls it; a plain `it` hangs instead of failing. Prefer
`CreateApiMock`/`LoadStub` over calling a real binary. New fakes (`fake_api`,
`fake_process`, `fake_watcher`, `temp_project`, `with_test_app`) land with the
coverage phases; use the existing specs as the pattern until then.

## Async Tests

Use `nio.tests` so the spec runs in a coroutine:

```lua
local nio = require("nio")
local a = nio.tests

describe("async behavior", function()
  a.it("completes without sleeping", function()
    local value
    nio.run(function()
      value = "done"
    end)
    nio.sleep(0)

    assert.equals("done", value)
  end)
end)
```

Do not use wall-clock sleeps. If a test needs to wait for a callback, use
`nio.sleep(0)`/`vim.wait` with a bounded condition and a useful failure
message.

## Buffer and UI Integration Tests

Copy the `with_buffer` pattern from
`tests/unit/completion/model_completion_identification_spec.lua`:

```lua
local function with_buffer(lines, cursor, fn)
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_set_current_buf(bufnr)
  vim.api.nvim_win_set_cursor(0, cursor)

  local ok, err = pcall(fn, bufnr)
  vim.api.nvim_buf_delete(bufnr, { force = true })
  if not ok then
    error(err)
  end
end
```

Always delete temporary buffers and restore window state. For extmarks, assert
on positions and virtual text, not on rendered screenshots.

## Ambient Effects Policy

- Unit and component tests must not spawn subprocesses, open network
  connections, watch the filesystem, or require external binaries.
- Integration tests may use temp files and flake-provided `rg`/`jq`; they still
  do not touch the network.
- Never write to `$HOME`, `stdpath('data')`, or a developer's Laravel project.
  Use `vim.fn.tempname()` and clean it up.
- Use `fake_watcher` for consumer tests. The real watcher's fs-event, debounce,
  and scan behavior belongs in integration tests with temp directories.
- Use an injected clock/timer for cache TTL and polling. No sleeps.

## Coverage Manifest

`tests/coverage_manifest.lua` maps feature areas to specs. Add an entry when a
new area gets its first spec:

```lua
{
  name = "route-info",
  status = "covered",
  specs = { "tests/integration/extensions/route_info_spec.lua" },
},
```

Run `make coverage-check`. It fails when a listed spec is missing or a spec file
is not listed. It reports pending areas. `--strict` also fails on pending areas
and is enabled once the roadmap is complete:

```bash
nvim -l scripts/coverage-check.lua --strict
```

## Lint Baseline

`make lint` runs stylua, luacheck, and selene. Errors block. A documented
baseline of unused/shadowing/line-length warnings is currently non-blocking
while the existing code is cleaned up incrementally; new errors still fail.
`tests/minimal_init.lua` is excluded from selene because it assigns test
globals.

## Troubleshooting

- `Missing test dependencies` — run from the repository root inside
  `nix develop`; for non-Nix setups run `make deps` and export
  `LARAVEL_TEST_DEPS`.
- Parser errors in completion tests — the devShell exports
  `LARAVEL_TS_PARSERS`; run through `nix develop`.
- A file-scoped run behaves differently from a directory run — the runner uses
  `require('plenary.busted').run(<absolute path>)` under
  `tests/minimal_init.lua`; keep new runner code on that path.
- CI is red but local `make test` is green — check the failing job command,
  then run the same command locally inside `nix develop`.
- Reproducing the 0.10 compatibility job — the flake parsers target the
  devShell ABI, so that job unsets `LARAVEL_TS_PARSERS` and sets
  `LARAVEL_SKIP_PARSER_SPECS=1`; parser-dependent specs skip while the rest of
  the fast suite runs.
