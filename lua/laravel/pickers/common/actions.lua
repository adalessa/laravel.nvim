local lsp = require("laravel._lsp")
local app = require("laravel").app
local ui_run = require("laravel.pickers.common.ui_run")

local M = {}

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

function M.run(command)
  vim.schedule(function()
    ui_run(command)
  end)
end

function M.open_route(route)
  vim.schedule(function()
    go(route)
  end)
end

function M.open_browser(route)
  app("configs_repository"):get("app.url"):thenCall(function(app_url)
    local uri = route.uri
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

    vim.fn.system({ command, url })
  end)
end

function M.make_run(command)
  vim.schedule(function()
    app("runner"):run("artisan", { command.name }, { ui = "popup" })
  end)
end

function M.open_relation(relation)
  vim.schedule(function()
    local action = vim.fn.split(relation.class, "@")
    lsp.go_to(action[1], action[2])
  end)
end

function M.open_resource(resource)
  local command = "ls -1 -A " .. resource.path
  local handle = io.popen(command)
  if not handle then
    vim.notify("Could not open the resource", vim.log.levels.WARN)
    return
  end

  local output = handle:read("*a")
  handle:close()

  if not output then
    vim.notify("Could not read the resource", vim.log.levels.WARN)
    return
  end

  local lines = vim
    .iter(vim.split(output, "\n"))
    :filter(function(line)
      return line ~= ""
    end)
    :totable()

  vim.ui.select(lines, {
    prompt = "Resources",
    kind = "resources",
  }, function(resource)
    if resource ~= nil then
      vim.cmd("edit " .. resource.path .. "/" .. resource.name)
    end
  end)
end

return M
