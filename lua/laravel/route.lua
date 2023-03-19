local Path = require "plenary.path"
local utils = require "laravel.utils"
---@class LaravelRoute
---@field uri string
---@field action string
---@field domain string|nil
---@field methods string[]
---@field middlewares string[]
---@field name string|nil

local M = {}

local function check_nil(value)
  if value == vim.NIL then
    return nil
  end
  return value
end

--- Gets list of routes from the raw json
---@param json string
---@return LaravelRoute[]
M.from_json = function(json)
  local routes = {}
  for _, route in ipairs(vim.fn.json_decode(json)) do
    table.insert(routes, {
      uri = route.uri,
      action = route.action,
      domain = check_nil(route.domain),
      methods = vim.fn.split(route.method, "|"),
      middlewares = route.middleware,
      name = check_nil(route.name),
    })
  end

  return routes
end

---@param route LaravelRoute
M.open = function(route)
  -- case 1 if action is clousure check middleware if web open routes/web.php,
  --            if middleware api open routes/api.php
  --        -- and look for the string of the route like full string, if does not find it look second row
  if route.action == "Closure" then
    if vim.tbl_contains(route.middlewares, "api") then
      vim.cmd "edit routes/api.php"
      vim.fn.search(route.uri:gsub("api", "") .. "")
    elseif vim.tbl_contains(route.middlewares, "web") then
      vim.cmd "edit routes/web.php"
      if route.uri == "/" then
        vim.fn.search "['\"]/['\"]"
      else
        vim.fn.search("/" .. route.uri)
      end
    else
      utils.notify("Route", { msg = "Could not open the route location", level = "WARN" })
    end

    vim.cmd "normal zt"
    return
  end

  local clients = vim.lsp.get_active_clients { name = "phpactor" }
  local client = clients[1] or nil
  local should_stop_server = false
  -- if not active I have to activate it
  if not client then
    local server = require("lspconfig")["phpactor"]
    local config = server.make_config(vim.fn.getcwd())
    local client_id = vim.lsp.start(config)
    client = vim.lsp.get_client_by_id(client_id)
    should_stop_server = true
  end
  if not client then
    utils.notify("Route open", { msg = "Can't get lsp client", level = "WARN" })
    return
  end

  local action = vim.fn.split(route.action, "@")

  local class_parts = vim.split(action[1], "\\")
  local class = class_parts[#class_parts]

  local resp = client.request_sync("workspace/symbol", { query = class }, nil)

  local locations = vim.lsp.util.symbols_to_items(resp.result or {}, nil) or {}
  if vim.tbl_isempty(locations) then
    utils.notify("Route Open", { msg = "Empty response looking for class: " .. route.action, level = "WARN" })
    if should_stop_server then
      vim.lsp.stop_client(client.id)
    end
    return
  end

  local class_location = nil
  for idx, location in pairs(locations) do
    if location.text == string.format("[Class] %s", action[1]) then
      class_location = locations[idx]
      break
    end
  end

  if class_location == nil then
    utils.notify("Route Open", { msg = "Could not find class for : " .. route.action, level = "WARN" })
    if should_stop_server then
      vim.lsp.stop_client(client.id)
    end
    return
  end

  local command = "edit"
  local filename = class_location.filename

  if vim.api.nvim_buf_get_name(0) ~= filename or command ~= "edit" then
    filename = Path:new(vim.fn.fnameescape(filename)):normalize(vim.loop.cwd())
    pcall(vim.cmd, string.format("%s %s", command, filename))
  end

  local params = vim.lsp.util.make_position_params(0)
  if should_stop_server then
    vim.lsp.buf_attach_client(0, client.id)
  end
  vim.lsp.buf_request(0, "textDocument/documentSymbol", params, function(method_err, method_server_result, _, _)
    if method_err then
      vim.api.nvim_err_writeln("Error when finding workspace symbols: " .. method_err.message)
      if should_stop_server then
        vim.lsp.stop_client(client.id)
      end
      return
    end

    local method_locations = vim.lsp.util.symbols_to_items(method_server_result or {}, 0) or {}
    if vim.tbl_isempty(method_locations) then
      utils.notify(
        "Route open",
        { msg = string.format("empty response looking for method: %s", action[2] or "__invoke"), level = "WARN" }
      )
      if should_stop_server then
        vim.lsp.stop_client(client.id)
      end
      return
    end

    local method_location = nil
    for _, value in ipairs(method_locations) do
      if value.text == string.format("[Method] %s", action[2] or "__invoke") then
        method_location = value
        break
      end
    end

    if method_location == nil then
      if should_stop_server then
        vim.lsp.stop_client(client.id)
      end
      return
    end

    local row = method_location.lnum
    local col = method_location.col - 1

    if row and col then
      local ok, err_msg = pcall(vim.api.nvim_win_set_cursor, 0, { row, col })
      if not ok then
        utils.notify("Route Open", { msg = "Erro setting row and col " .. err_msg, level = "WARN" })
      end
      vim.cmd "normal zt"
    end
    if should_stop_server then
      vim.lsp.stop_client(client.id)
    end
  end)
  -- to activate check that is configurated have the cmd from lspconfig
  -- once active have to look for the namespace
  -- case 2 if action is class look for the class and look for the invoke method.
  -- case 3 if action is class@method look for the class and method.
end

return M
