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

## References

- Design: `docs/superpowers/specs/2026-11-21-test-infrastructure-design.md`
- Foundation plan: `docs/superpowers/plans/2026-11-21-test-infrastructure-foundation.md`
- Test guide: `docs/testing.md`
- Coverage map: `tests/coverage_manifest.lua`
- CI: `.github/workflows/test.yml`
