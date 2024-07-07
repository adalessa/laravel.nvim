local phpactor = require "laravel._lsp.phpactor"
local intelephense = require "laravel._lsp.intelephense"
local app = require "laravel.app"

local servers = {
  phpactor = phpactor,
  intelephense = intelephense,
}

---@param server_name string
---@return table|nil, boolean
local get_client = function(server_name)
  local clients = vim.lsp.get_clients { name = server_name }
  local client = clients[1] or nil
  local new_instance = false

  if not client then
    local server = require("lspconfig")[server_name]
    local client_id = vim.lsp.start(server.make_config(vim.fn.getcwd()))
    if not client_id then
      error "Could not start lsp client"
    end
    client = vim.lsp.get_client_by_id(client_id)
    new_instance = true
  end

  return client, new_instance
end

---@param full_class string
---@param method string
local go_to = function(full_class, method)
  local server_name = app('options'):get().lsp_server

  local server = servers[server_name]
  if server == nil then
    vim.notify(string.format("No server with name %s found", server_name), vim.log.levels.WARN)
    return
  end

  local client, is_new_instance = get_client(server_name)

  if not client then
    vim.notify("Can't get lsp client", vim.log.levels.WARN)
    return
  end

  return server.go_to(client, is_new_instance, full_class, method)
end

return {
  go_to = go_to,
}
