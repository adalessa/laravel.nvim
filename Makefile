NVIM ?= nvim
SHELL := bash
export NVIM

.PHONY: test test-integration test-all test-file test-scripts deps lint format coverage-check ci

test:
	scripts/test.sh --unit --component

test-integration:
	scripts/test.sh --integration

test-all:
	scripts/test.sh --all

test-file:
	@test -n "$(FILE)" || (echo "usage: make test-file FILE=<path>" >&2; exit 2)
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
