local phpactor = require "laravel._lsp.phpactor"
local intelephense = require "laravel._lsp.intelephense"
local utils = require "laravel.utils"
local application = require "laravel.application"

local servers = {
  phpactor = phpactor,
  intelephense = intelephense,
}

---@param server_name string
---@return table|nil, boolean
local get_client = function(server_name)
  local clients = vim.lsp.get_active_clients { name = server_name }
  local client = clients[1] or nil
  local new_instance = false

  if not client then
    local server = require("lspconfig")[server_name]
    local config = server.make_config(vim.fn.getcwd())
    local client_id = vim.lsp.start(config)
    client = vim.lsp.get_client_by_id(client_id)
    new_instance = true
  end

  return client, new_instance
end

---@param full_class string
---@param method string
local go_to = function(full_class, method)
  local server_name = application.get_options().lsp_server

  local server = servers[server_name]
  if server == nil then
    utils.notify("Route open", { msg = "No server name " .. server_name, level = "WARN" })
    return
  end

  local client, is_new_instance = get_client(server_name)

  if not client then
    utils.notify("Route open", { msg = "Can't get lsp client", level = "WARN" })
    return
  end

  return server.go_to(client, is_new_instance, full_class, method)
end

return {
  go_to = go_to,
}
