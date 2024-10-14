local common_actions = require("laravel.pickers.common.actions")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local ui_run = require("laravel.pickers.telescope.ui_run")
local app = require("laravel").app

local M = {}

function M.run(prompt_bufnr)
  actions.close(prompt_bufnr)
  local entry = action_state.get_selected_entry()
  local command = entry.value

  common_actions.run(command, ui_run)
end

function M.make_run(prompt_bufnr)
  actions.close(prompt_bufnr)
  local entry = action_state.get_selected_entry()
  local command = entry.value

  common_actions.make_run(command)
end

function M.open_route(prompt_bufnr)
  actions.close(prompt_bufnr)
  local entry = action_state.get_selected_entry()

  common_actions.open_route(entry.value)
end

function M.open_browser(prompt_bufnr)
  actions.close(prompt_bufnr)
  local entry = action_state.get_selected_entry()

  common_actions.open_browser(entry.value)
end

function M.re_run_command(prompt_bufnr)
  actions.close(prompt_bufnr)
  local entry = action_state.get_selected_entry()

  app("runner"):run(entry.value.name, entry.value.args, entry.value.opts)
end

function M.open_relation(prompt_bufnr)
  actions.close(prompt_bufnr)
  local entry = action_state.get_selected_entry()

  common_actions.open_relation(entry.value)
end

return M
