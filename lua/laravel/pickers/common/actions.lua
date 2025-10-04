local app = require("laravel.core.app")
local ui_run = require("laravel.pickers.common.ui_run")
local preview = require("laravel.pickers.common.preview")
local nio = require("nio")
local notify = require("laravel.utils.notify")

local M = {}

local function go(route)
  if route.action == "Closure" or route.action == "Illuminate\\Routing\\ViewController" then
    if vim.tbl_contains(route.middlewares, "api") then
      vim.cmd("edit routes/api.php")
      vim.fn.search(route.uri:gsub("api", "") .. "")
    elseif vim.tbl_contains(route.middlewares, "web") then
      vim.cmd("edit routes/web.php")
      if route.action == "Illuminate\\Routing\\ViewController" then
        vim.fn.search(string.format("Rotue::view(['\"]%s['\"])", route.uri))
      else
        if route.methods[1] == "GET" then
          vim.fn.search(string.format("Route::get(['\"]%s['\"])", route.uri))
        elseif route.methods[1] == "POST" then
          vim.fn.search(string.format("Route::post(['\"]%s['\"])", route.uri))
        elseif route.methods[1] == "PUT" then
          vim.fn.search(string.format("Route::put(['\"]%s['\"])", route.uri))
        elseif route.methods[1] == "DELETE" then
          vim.fn.search(string.format("Route::delete(['\"]%s['\"])", route.uri))
        elseif route.methods[1] == "PATCH" then
          vim.fn.search(string.format("Route::patch(['\"]%s['\"])", route.uri))
        else
          if route.uri == "/" then
            vim.fn.search("['\"]/['\"]")
          else
            vim.fn.search("/" .. route.uri)
          end
        end
      end
    else
      notify.warn("Could not open the route location")
      return
    end

    vim.cmd("normal zt")
    return
  end

  nio.run(function()
    local res, err = app("laravel.services.class_finder"):find(route.action)
    if not err then
      local file, line = res.file, res.line
      vim.schedule(function()
        if pcall(vim.cmd.edit, file) then
          pcall(vim.api.nvim_win_set_cursor, 0, { line, 0 })
          pcall(vim.cmd.normal, "zt")
        end
      end)
    end
  end)
end

function M.artisan_run(command)
  vim.schedule(function()
    ui_run(command, {
      title = "Artisan",
      prompt = "$ artisan " .. command.name .. " ",
      on_submit = function(input)
        local args = vim.fn.split(input, " ", false)
        table.insert(args, 1, command.name)

        app("runner"):run("artisan", args)
      end,
      preview = preview.command(command),
    })
  end)
end

function M.composer_run(command)
  vim.schedule(function()
    ui_run(command, {
      title = "Composer",
      prompt = "$ composer " .. command.name .. " ",
      on_submit = function(input)
        local args = vim.fn.split(input, " ", false)
        table.insert(args, 1, command.name)

        app("runner"):run("composer", args)
      end,
      preview = preview.composer(command),
    })
  end)
end

function M.open_route(route)
  vim.schedule(function()
    go(route)
  end)
end

function M.open_browser(route)
  nio.run(function()
    local app_url, err = app("laravel.loaders.configs_loader"):get("app.url")
    if err then
      return notify.error("Could not load app.url: " .. err:toString())
    end
    local uri = route.uri
    for capturedString in uri:gmatch("{(.-)}") do
      local val = nio.fn.input({ prompt = capturedString .. ": " })
      uri = uri:gsub("{" .. capturedString .. "}", val)
    end

    local url = string.format("%s/%s", app_url, uri)
    local command = nil

    if nio.fn.executable("xdg-open") == 1 then
      command = "xdg-open"
    elseif nio.fn.executable("open") == 1 then
      command = "open"
    end
    if not command then
      return
    end

    nio.fn.system({ command, url })
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
    notify.warn("Could not open the resource")
    return
  end

  local output = handle:read("*a")
  handle:close()

  if not output then
    notify.warn("Could not read the resource")
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
