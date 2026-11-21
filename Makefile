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
	# Warnings are reported but not blocking while the baseline is cleaned up.
	# minimal_init is a bootstrap shim that assigns test globals; it is excluded.
	selene --allow-warnings lua tests/unit tests/support

format:
	stylua lua tests

coverage-check:
	nvim -l scripts/coverage-check.lua

ci: lint test-scripts test coverage-check
