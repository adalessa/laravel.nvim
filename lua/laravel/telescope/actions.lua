local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local ui_run = require "laravel.telescope.ui_run"
local go = require "laravel.routes.go"
local run = require "laravel.run"
local lsp = require "laravel._lsp"

local M = {}

function M.run(prompt_bufnr)
  actions.close(prompt_bufnr)
  local entry = action_state.get_selected_entry()
  local command = entry.value

  vim.schedule(function()
    ui_run(command)
  end)
end

function M.open_route(prompt_bufnr)
  actions.close(prompt_bufnr)
  local entry = action_state.get_selected_entry()
  vim.schedule(function()
    go(entry.value)
  end)
end

function M.re_run_command(prompt_bufnr)
  actions.close(prompt_bufnr)
  local entry = action_state.get_selected_entry()
  run(entry.value.name, entry.value.args, entry.value.opts)
end

function M.open_relation(prompt_bufnr)
  actions.close(prompt_bufnr)
  local entry = action_state.get_selected_entry()
  vim.schedule(function()
    local action = vim.fn.split(entry.value.class, "@")
    lsp.go_to(action[1], action[2])
  end)
end

return M
