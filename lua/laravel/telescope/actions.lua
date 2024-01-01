local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local ui_run = require "laravel.telescope.ui_run"
local go = require "laravel.routes.go"
local run = require "laravel.run"
local lsp = require "laravel._lsp"
local config = require "laravel.app.config"

local M = {}

function M.run(prompt_bufnr)
  actions.close(prompt_bufnr)
  local entry = action_state.get_selected_entry()
  local command = entry.value

  vim.schedule(function()
    ui_run(command)
  end)
end

function M.run_asking_options(prompt_bufnr)
  actions.close(prompt_bufnr)
  local entry = action_state.get_selected_entry()
  local command = entry.value

  vim.schedule(function()
    ui_run(command, true)
  end)
end

function M.open_route(prompt_bufnr)
  actions.close(prompt_bufnr)
  local entry = action_state.get_selected_entry()
  vim.schedule(function()
    go(entry.value)
  end)
end

function M.open_browser(prompt_bufnr)
  actions.close(prompt_bufnr)
  local entry = action_state.get_selected_entry()
  local app_url = config.get "app.url"
  if not app_url then
    return
  end

  local uri = entry.value.uri
  for capturedString in uri:gmatch "{(.-)}" do
    -- TODO: replace with vim.ui.input resolve the async
    local val = vim.fn.input(capturedString .. ": ")
    uri = uri:gsub("{" .. capturedString .. "}", val)
  end

  local url = string.format("%s/%s", app_url, uri)
  local command = nil

  if vim.fn.executable "xdg-open" == 1 then
    command = "xdg-open"
  elseif vim.fn.executable "open" == 1 then
    command = "open"
  end
  if not command then
    return
  end

  vim.schedule(function()
    vim.fn.system { command, url }
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
