# Agent Guide

This repository is a Neovim plugin (`laravel.nvim`). The test suite is the
feedback loop for agent-assisted changes. Read `docs/testing.md` before adding
or changing tests.

## Quickstart

```bash
nix develop          # provides Neovim, test plugins, parsers, PHP, and linters
make test            # unit + component, hermetic, target < 15s
make test-integration
make test-all
```

Run `make test-file FILE=tests/unit/path/to/spec.lua` while iterating. Run the
targeted spec first, then the full suite before committing.

## How the Infrastructure Fits Together

```text
flake.nix
  -> nix develop exports LARAVEL_TEST_DEPS and LARAVEL_TS_PARSERS
tests/minimal_init.lua
  -> tests/support/deps.lua resolves plugins and appends runtimepath
scripts/test.sh
  -> plenary runner used by the Makefile and GitHub Actions
tests/coverage_manifest.lua
  -> feature-area coverage gate run by make coverage-check
```

`make test` is the fast hermetic loop. `make test-integration` is for real
headless Neovim behavior. `make test-all` runs both. CI calls the same targets,
so local and CI behavior do not drift.

`make deps` is the non-Nix fallback for plugins only; it cannot build the
PHP/JSON tree-sitter parsers. Use `nix develop` for parser-dependent specs.
The 0.10 compatibility job skips parser-dependent specs because the flake
parsers target the devShell ABI.

## Design Intent

- Optimize for agent velocity: a fast, deterministic unit/component loop with
  integration checks close behind.
- Keep the fast suite free of network, PHP, external binaries, `$HOME`, and real
  filesystem watchers.
- Track coverage by curated feature area, not one test per module.
- Treat bug fixes as regression tests and new behavior as test-first work.

## Layers

| Directory | Purpose | Allowed to touch |
| --- | --- | --- |
| `tests/unit` | Pure logic, DTOs, utils, mappers, options | No subprocesses, network, external binaries, `$HOME`, or real watchers |
| `tests/component` | Services, loaders, commands with fakes | Fake API/process/watcher/env; no real subprocesses |
| `tests/integration` | Headless Neovim buffers, extmarks, tree-sitter, provider boot | Temp files and flake-provided `rg`/`jq`; still no network |

`tests/support` holds shared setup and shell-level checks. `tests/stubs`
holds immutable JSON fixtures; planned project skeletons will live under
`tests/fixtures`.

## Rules

1. Write the failing test first for new behavior. Run it and watch it fail for
   the expected reason.
2. Add a regression test for every bug fix.
3. Keep `make test` hermetic and fast. Use fakes at the process, filesystem, and
   watcher boundaries.
4. Never read or write the user's real Neovim config, `stdpath('data')`, or
   Laravel projects. Use temp directories.
5. Do not mark a feature area `covered` in `tests/coverage_manifest.lua` without
   a spec.
6. Run `make lint` before committing. Warnings are reported but do not block
   yet; errors do.

## Existing Helpers

- `A(...)` prints `vim.inspect`.
- `LoadStub(path)` reads a fixture through `nio`; use `nio.tests` (`a.it`) for
  any spec that calls it.
- `CreateApiMock(check, response)` fakes the API service and records commands.

`fake_api`, `fake_process`, `fake_watcher`, `temp_project`, and `with_test_app`
arrive with the coverage phases. Until then, follow the patterns in
`docs/testing.md` and the existing specs.

## Coverage Roadmap

The manifest is the source of truth. Areas currently pending:

`bootstrap`, `container-factory`, `options-env`, `events`, `core-services`,
`commands`, `extensions-completion`, `model-info`, `route-info`, `diagnostics`,
`composer-info`, `tinker`, `command-center`, `artisan-hub`, `pickers`, `health`,
`e2e`.

When an area gets its first spec, change its status to `covered` and list every
new spec path in that entry. Every spec file must appear in the manifest.

## References

- Test guide: `docs/testing.md`
- Coverage map: `tests/coverage_manifest.lua`
- CI: `.github/workflows/test.yml`
- Environment: `flake.nix`, `flake.lock`
- Commands: `Makefile`, `scripts/test.sh`
