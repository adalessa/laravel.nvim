local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local ui_run = require("laravel.telescope.ui_run")
local lsp = require("laravel._lsp")
local app = require("laravel").app

local function go(route)
  if route.action == "Closure" or route.action == "Illuminate\\Routing\\ViewController" then
    if vim.tbl_contains(route.middlewares, "api") then
      vim.cmd("edit routes/api.php")
      vim.fn.search(route.uri:gsub("api", "") .. "")
    elseif vim.tbl_contains(route.middlewares, "web") then
      vim.cmd("edit routes/web.php")
      if route.uri == "/" then
        vim.fn.search("['\"]/['\"]")
      else
        vim.fn.search("/" .. route.uri)
      end
    else
      vim.notify("Could not open the route location", vim.log.levels.WARN)
      return
    end

    vim.cmd("normal zt")
    return
  end

  local action = vim.fn.split(route.action, "@")
  lsp.go_to(action[1], action[2])
end

local M = {}

function M.run(prompt_bufnr)
  actions.close(prompt_bufnr)
  local entry = action_state.get_selected_entry()
  local command = entry.value

  vim.schedule(function()
    ui_run(command)
  end)
end

function M.make_run(prompt_bufnr)
  actions.close(prompt_bufnr)
  local entry = action_state.get_selected_entry()
  local command = entry.value

  vim.schedule(function()
    app("runner"):run("artisan", { command.name }, { ui = "popup" })
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
  local app_url = nil
  app("configs")
      :get(function(value)
        app_url = value["app.url"]
      end)
      :wait()
  if not app_url then
    return
  end

  local uri = entry.value.uri
  for capturedString in uri:gmatch("{(.-)}") do
    local val = vim.fn.input(capturedString .. ": ")
    uri = uri:gsub("{" .. capturedString .. "}", val)
  end

  local url = string.format("%s/%s", app_url, uri)
  local command = nil

  if vim.fn.executable("xdg-open") == 1 then
    command = "xdg-open"
  elseif vim.fn.executable("open") == 1 then
    command = "open"
  end
  if not command then
    return
  end

  vim.schedule(function()
    vim.fn.system({ command, url })
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
