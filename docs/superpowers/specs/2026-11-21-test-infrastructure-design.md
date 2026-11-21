# Test Infrastructure for Agent-Velocity Development

Date: 2026-11-21
Status: approved
Issue: adalessa/laravel.nvim#197 ("Improve Testing")

## Intent

The owner wants to ship more features, faster, with agents doing much of the
work. The test suite is not a coverage exercise; it is the feedback loop that
makes agent-assisted changes safe. A change is "fast" only if an agent can
run a reliable check in seconds, see a clear failure, and know which behavior
it broke.

Issue #197 asks to "automate the project by adding tests as much as possible".
This design turns that into infrastructure first, coverage second:

1. A reproducible environment (Nix flake) so no one guesses at dependencies.
2. A CI pipeline that enforces the suite on every pull request.
3. A hermetic, layered test suite with helpers that make new tests cheap.
4. A documented agent workflow (commands, recipes, where tests live).
5. A risk-ordered coverage roadmap for the existing feature set.

## Current State

- 213 Lua modules, ~11,900 lines under `lua/`.
- 9 spec files, ~600 lines under `tests/unit/`.
- Covered today: cache service, error util, buffer util, command generator,
  API response DTO, artisan/routes/user-commands loaders, and the model
  completion resolver (uses real headless buffers).
- Not covered: bootstrap, container/factory, options manager, env, validation,
  events, watcher, most services, most loaders, commands, all four picker
  providers, and most extension UI (model info, route info, diagnostics,
  composer info, tinker, command center, artisan hub, override).
- No GitHub Actions workflow, no documented test command, and no lint gate in
  CI. `tests/minimal_init.lua` assumes dependencies are installed under a
  lazy.nvim `stdpath`, which is not true on a fresh machine or in CI.
- The local machine has `nix` and `gh`, but no `php`, `composer`, or `make`.
  Neovim is available; the plugin advertises support for Neovim >= 0.10.
- Baseline run with manually supplied Nix plugin paths: 29 pass, 12 fail. All
  twelve failures are the model-completion spec, caused by the PHP tree-sitter
  parser being absent: `vim.treesitter.get_parser(bufnr, "php")` returns nil
  and `.parse()` raises a nil-index error inside
  `model_completion_type_resolver.lua`. The flake must provide the PHP and JSON
  parsers, and the resolver should fail with a deliberate, testable error when
  a parser is unavailable (see Testability Enablers).
- `.gitignore` already ignores `/.tests`, `.direnv`, and devenv artifacts.

## Goals

- A fresh clone can reach a green suite with two commands:
  `nix develop` then `make test`.
- `make test` (unit + component) runs hermetically in under ~15 seconds: no
  network, no PHP, no user config, no sleeps, no external binaries, no
  dependence on the developer's Laravel app.
- Integration tests run headless Neovim against temporary fixture projects and
  deterministic fakes; they do not require a real Laravel installation.
- CI runs unit, integration, and lint on every PR, with failures attributable
  to one layer.
- Adding a test is an obvious, documented action for an agent: named helpers,
  a feature-to-spec map, and copyable recipes.
- Every existing feature area has at least one behavioral test and a named
  home in the suite.
- Bug fixes are expected to land with a regression test; new behavior is
  expected to start with a failing test (TDD).

## Non-Goals

- 100% line coverage. Coverage is tracked as a feature map, not a percentage
  gate.
- Replacing plenary/busted with another runner.
- Testing third-party picker internals (telescope, fzf-lua, snacks, ui.select).
- Windows CI in the first iteration.
- Performance benchmarking or load testing.
- Refactoring production modules that do not need a seam yet.

## Anti-Goals

- Tests that silently depend on the developer's real Laravel project, global
  Neovim config, network, or `$HOME`.
- Flaky tests based on filesystem timing, real filesystem watchers, or sleeps.
- A CI pipeline that takes longer than ~10 minutes or that mixes lint, unit,
  and integration failures into one opaque job.
- A large speculative refactor before the safety net exists.

## Decisions From Conversation

- The primary motivation is agent-assisted velocity and regression safety, not
  coverage metrics.
- Dependency provisioning comes first: `flake.nix`, then GitHub CI.
- Integration and TDD are both in scope, along with tooling improvements.
- The plugin's existing plenary-based specs are the starting point.

## My Calls (owner can override)

- **Runner:** keep plenary/busted, including `nio.tests` for async. It is
  already used and works headless.
- **Required suite is hermetic:** fakes and golden fixtures, no real PHP. A real
  Laravel end-to-end job is optional/nightly, not a required PR gate.
- **Entry point:** `make` targets delegating to one shell script, so humans and
  agents use the same commands and CI does not duplicate logic.
- **CI matrix:** required jobs use the flake's pinned stable Neovim. A separate
  non-blocking compatibility job covers 0.10.x and nightly.
- **Coverage gate:** a checked-in feature manifest maps curated feature areas
  (roughly 20-30, not all 213 modules) to one or more specs.
  `make coverage-check` fails when a listed spec is missing or a spec file is
  not listed, and it reports feature areas still marked `pending`. A
  `--strict` mode also fails on pending areas and is enabled once the roadmap
  is complete. The manifest is reviewed when a feature area is added. It does
  not require one spec per production module; modules are covered through
  behavior tests. The non-strict check is required in CI. No line-coverage
  percentage gate initially.
- **Lint:** add `make lint`; make the CI lint job required only after the
  existing baseline is cleaned up (tracked as a phase task).
- **Platforms:** devShell supports Linux and macOS; CI runs on Ubuntu initially.
- **PHP/composer:** included in the flake for the optional real end-to-end job
  and manual debugging, not for the required suite.

## Architecture

### Test Layers

1. **Unit (hermetic, fast)** — pure Lua logic and Neovim-independent modules:
   utils, DTOs, mappers, options merging, container/factory, validation.
   Mocks only the Neovim API where unavoidable.
2. **Component contract** (`tests/component/`) — services, loaders, commands,
   events, and watcher consumers with fakes: fake API responses, fake process
   runner, fake watcher, fake environment/cwd, temp config paths. No real
   subprocesses, network, or external binaries.
3. **Headless integration** (`tests/integration/`) — real Neovim buffers,
   windows, extmarks, and tree-sitter parsers against a temporary fixture
   project: completion source, model/route info, diagnostics, composer info,
   picker adapters, bootstrap and provider registration, and dispatch through
   `Laravel.commands.run` and provider-registered functions.
4. **Optional end-to-end (CI only)** — a minimal real Laravel fixture invoked
   with PHP/artisan to validate the API contract. Non-blocking and clearly
   separated.

Tests should live at the lowest layer that can prove the behavior. A bug found
in integration gets a regression test at the lowest layer that reproduces it.

### Directory Layout

```text
flake.nix
flake.lock
Makefile
scripts/
  test.sh                 # single test entry point, layer/file/filter aware
  coverage-check.lua      # validates tests/coverage_manifest.lua
tests/
  minimal_init.lua        # dependency resolution + headless setup
  helpers/
    fake_api.lua
    fake_process.lua
    fake_watcher.lua
    fake_env.lua
    temp_project.lua
    buffer.lua
    fixtures.lua
    assertions.lua
  fixtures/
    stubs/                # existing JSON payloads, more added over time
    projects/             # generated or checked-in minimal project skeletons
  coverage_manifest.lua   # feature area -> spec files (checked in)
  unit/
  component/
  integration/
```

Existing specs move only if a move earns its keep; no churn for its own sake.

### Runner and Dependency Resolution

`tests/minimal_init.lua` resolves dependencies in this order:

1. `$LARAVEL_TEST_DEPS` (set by the Nix devShell).
2. `.tests/deps/` (managed by `make deps` for non-Nix users).
3. The legacy lazy.nvim `stdpath` location.

If a dependency is missing, the init fails immediately with the plugin names
and the fix (`nix develop` or `make deps`). It never silently continues.

`scripts/test.sh` supports:

- `--unit` (pure logic only)
- `--component` (services/loaders/commands with fakes)
- `--integration` (headless Neovim behavior)
- `--all`
- `--file <path>`
- `--filter <pattern>`
- `--list` (prints the resolved spec set without running)

`Makefile` targets:

- `make test` — unit + component, the default fast feedback loop (target under
  ~15 seconds)
- `make test-integration`
- `make test-all`
- `make test-file FILE=<path>`
- `deps`, `lint`, `format`, `coverage-check`, `ci`

### Hermetic Fakes and Fixtures

- `fake_api` returns scripted `ApiResponse` objects and records every command.
  It replaces ad-hoc `CreateApiMock` construction and supports success, failure,
  malformed JSON, and delayed/async responses.
- `fake_process` is the seam for `nio.process.run`; it drives the API service
  without spawning anything.
- `fake_watcher` records registrations and exposes `trigger(path)` explicitly.
  No real filesystem watchers in tests.
- `fake_env` controls cwd, executable lookup, and environment selection.
- `temp_project` creates an isolated directory with `artisan`, `composer.json`,
  `routes/`, `app/Models`, and a writable `vendor/` placeholder. Tests always
  clean it up; nothing writes to `$HOME`.
- `buffer.with_buffer(lines, cursor, fn)` and a `wait_for` helper for `nio`
  async assertions. Helpers must time out with a useful message, never sleep.
- Fixtures are immutable and shared by layer. New command output formats get a
  new stub, not a live call.
- `with_test_app(fn)` creates an app/container for a test. If provider boot
  requires the global `Laravel` table, the helper installs it, snapshots the
  previous value, and restores it in `after_each`. Tests must not leak globals
  or container state. Production providers are not rewritten to avoid globals
  during the foundation phases; a seam is added only if a test cannot be
  isolated otherwise.

### Ambient Effects Policy

- **Unit and component tests** must not spawn subprocesses, open network
  connections, watch the filesystem, or require external binaries. Where the
  behavior under test crosses one of these boundaries, use the named seam
  (`fake_process`, `fake_watcher`, `fake_env`) or a `luassert` mock of
  `vim.fn`/`io`. Tests may use temporary directories, but never `$HOME`,
  `stdpath('data')`, or the developer's config.
- **Integration tests** may use real temporary files and the flake-provided
  `rg`/`jq`; they still do not touch the network. Real subprocesses are used
  only when the process contract itself is under test.
- **`stdpath('data')` paths** in bootstrap, logging, and options saving must be
  overridable via an explicit path or environment variable so tests can point
  them at a temp directory.
- **Watcher and timers:** fast tests assert consumer registration with
  `fake_watcher`. The real `core/watcher.lua` fs-event, debounce, and recursive
  scan behavior is covered in the integration layer with temp directories and
  bounded `wait_for` assertions. Cache TTL and status polling use an injected
  clock or timer seam; no test sleeps.
- **Picker/completion plugins:** the flake provides telescope, fzf-lua, snacks,
  nvim-cmp, and blink.cmp so adapter modules can load. Required adapter
  contract tests use thin fakes of the plugin APIs and assert our entry data
  and action dispatch; plugin rendering is out of scope. A small integration
  smoke test may load the real plugins headlessly if it stays stable.

### Flake

`flake.nix` with `nixpkgs` and `flake-utils` inputs, a committed `flake.lock`,
and one `devShells.default` providing:

- Neovim (pinned, satisfying >= 0.10), `git`, `ripgrep`, `jq`, `make`
- `stylua`, `luacheck`, `selene`
- `php` and `composer` (optional e2e/manual use)
- plenary.nvim, nvim-nio, nui.nvim, nvim-treesitter with PHP and JSON parsers
- telescope.nvim, fzf-lua, snacks.nvim, nvim-cmp, and blink.cmp for adapter
  loading and optional smoke tests

The shell hook links test dependencies into `.tests/deps/`, sets
`LARAVEL_TEST_DEPS`, and exports `LARAVEL_TS_PARSERS` as a colon-separated list
of grammar/query store paths so headless tests can attach PHP/JSON tree-sitter
parsers without downloading anything. `direnv` support is optional, not
required.

A `checks` output (or `make ci`) runs lint and the fast suite so
`nix flake check` is meaningful, but the primary interface remains
`nix develop --command make ...`.

### CI

`.github/workflows/test.yml`, triggered on pull requests, pushes to the
default branch, and manual dispatch:

- **fast** — install Nix, restore cache,
  `nix develop --command make test` (unit + component).
- **integration** — same setup, `make test-integration`.
- **coverage** — `make coverage-check`.
- **lint** — `make lint` (required once the baseline is clean).
- **compat (non-blocking)** — Neovim 0.10.x and nightly fast suite, using the
  `NVIM` override so the flake still provides test dependencies. Flake-built
  tree-sitter parsers target the devShell ABI, so this job unsets
  `LARAVEL_TS_PARSERS` and sets `LARAVEL_SKIP_PARSER_SPECS=1`; parser-dependent
  specs skip rather than failing on an ABI mismatch. Version-specific parser
  coverage on 0.10 would require a separate grammar build.
- **e2e (non-blocking, optional/nightly)** — added by the Phase 8 plan; it is
  not part of the foundation workflow because the real Laravel fixture does not
  exist yet.

`make lint` covers `lua/` and `tests/`: `stylua --check`, `luacheck`, and
`selene`. Phase 2 may include a mechanical formatting commit and linter-config
updates for test globals. The job is blocking once the baseline is clean; this
is not deferred to a later branch-protection change.

Rules: each job has a timeout, prints the exact command and spec set, uploads
failure artifacts/logs, and does not share mutable state with other jobs. CI
uses the same `make` targets as humans; no logic lives only in workflow YAML.

### Agent Workflow

`AGENTS.md` at the repository root, with a deeper `docs/testing.md`:

- The two-command quickstart and the difference between unit and integration.
- A feature-to-spec map generated from `coverage_manifest.lua`.
- Recipes: add a unit test, test a loader with `fake_api`, test a service with
  `fake_process`, test buffer/UI behavior, test async code with `nio.tests`,
  create a temp project, assert an error, add a fixture.
- Rules: write the failing test first for new behavior; add a regression test
  for every bug fix; keep unit tests hermetic; prefer fakes to real processes;
  run the targeted spec before the full suite; never edit the manifest to hide
  a gap.
- Runtime budgets, so agents notice when a test is unexpectedly slow.

## Testability Enablers (Production Seams)

These are small, behavior-preserving changes that unlock testing. They are
scheduled only when a phase needs them.

1. **Process seam** — `laravel.services.process` wrapping `nio.process.run`,
   injected into `services/api.lua` and other subprocess users. Unit tests
   inject `fake_process`; production uses nio.
2. **Filesystem/cwd seam** — explicit cwd and file access for `core/env.lua`,
   `services/path.lua`, and `core/options_manager.lua`. Tests never rely on the
   real cwd or `$HOME`.
3. **Options isolation** — make `core/options_manager.lua` resettable or
   instance-based so module-level state cannot leak between specs.
4. **Bootstrap injection** — allow a custom provider list and avoid eager
   provider requires, so a test can boot only what it needs.
5. **Watcher injection** — already designed for injection; add a fake and
   document it as the standard.
6. **UI handler/picker split** — separate entry building and actions from
   provider adapters so formatting and action logic are testable without
   telescope/fzf-lua/snacks.
7. **Test app builder** — a helper that creates an app with container bindings,
   installs `_G.Laravel` only when a provider requires it, and restores the
   previous global during teardown.
8. **Command execution seam** — `base_command`/`term_command`/`pty_command`
   job start and buffer access behind a fakeable boundary.
9. **Parser availability** — `model_completion_type_resolver` and any other
   tree-sitter consumer must check for a parser and return a deliberate error
   (or skip) instead of raising a nil-index error. This is both a production
   robustness fix and a prerequisite for reliable headless tests.

The reflective factory (`debug.getlocal`) is covered by tests but not rewritten
unless it blocks a test; it is high-risk and deserves characterization tests
first.

## Coverage Roadmap

Each phase ends with a green suite and a demonstrable command. Phases are
ordered by risk and by how much they unblock agent work.

1. **Foundation** — `flake.nix`/lock, `make deps`, rewritten `minimal_init`,
   `scripts/test.sh`, and a baseline green run of the existing 9 specs. This
   includes providing PHP/JSON parsers and fixing the unguarded parser lookup
   so the model-completion spec goes from 12 failures to green.
2. **CI and docs** — workflow (fast/integration/coverage/lint), `AGENTS.md`,
   `coverage_manifest.lua`, `coverage-check`, lint baseline cleanup.
3. **Core and primitives** — container, factory, app, options manager, env,
   validation, events, string/class/fs/notify utilities, DTOs, mappers,
   options defaults. Watcher consumers use `fake_watcher`; the real watcher's
   fs-event/debounce/scan behavior gets an integration spec with temp dirs.
4. **Services and loaders** — API, command generator, class/class_finder,
   code, gf, model, related, livewire, path, status, ui/history, composer,
   inertia, views, tinker, view_finder, eloquent helper; all loaders including
   cache loaders, with fake API/process/watcher.
5. **Commands and events** — artisan, composer, make, related, resources,
   routes, history, user commands, configure, flush cache, open config/logs,
   view finder, runner, term/pty commands, event dispatch and listeners.
6. **Extensions and UI behavior** — completion sources, model info, route info
   views, diagnostics, composer info, tinker, command center, artisan hub,
   override, health; headless buffer/extmark assertions and tree-sitter.
7. **Pickers** — shared actions/preview, then contract tests for telescope,
   fzf-lua, snacks, and ui.select adapters (entry formatting and action
   dispatch, not plugin internals).
8. **Optional end-to-end** — real Laravel fixture, PHP/artisan, nightly CI.

## Success Criteria

- Fresh clone to green: `nix develop` + `make test` works with no manual
  plugin installation.
- Fast suite (unit + component) is hermetic and under ~15 seconds locally.
- `make test-all` (unit + component + integration) under ~60 seconds excluding
  optional e2e.
- CI required jobs are green and each failure identifies its layer.
- The coverage manifest reports no feature area without a spec.
- A sample agent task ("add a regression test for X and fix it") can be
  completed using only `AGENTS.md` and the helpers.
- Every subsequent feature PR includes tests; bug-fix PRs include a regression
  test.

## Left to the Builder

- Exact Nix package names and how tree-sitter parsers are wired into the
  headless runtime.
- Whether `scripts/test.sh` uses plenary's `PlenaryBustedDirectory` or a
  per-file `PlenaryBustedFile` loop, and how filters are implemented.
- Helper APIs and names, as long as the behaviors above are met.
- Which existing specs move into `integration/`, if any.
- Exact CI action versions and cache strategy.
- How the coverage manifest is structured, as long as missing entries fail the
  check.
- How far to take the production seams in each phase, provided behavior does
  not change.
