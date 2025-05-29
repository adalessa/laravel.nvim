local phpactor = require("laravel._lsp.phpactor")
local intelephense = require("laravel._lsp.intelephense")
local app = require("laravel").app
local notify = require("laravel.utils.notify")

local servers = {
  phpactor = phpactor,
  intelephense = intelephense,
}

---@param server_name string
---@return table|nil, boolean
local get_client = function(server_name)
  local clients = vim.lsp.get_clients({ name = server_name })
  local client = clients[1] or nil
  local new_instance = false

  if not client then
    local ok, lsp_config = pcall(require, "lspconfig")
    local config = {}
    if not ok then
      config = vim.lsp.config[server_name]
    else
      local server = lsp_config[server_name]
      config = server.make_config(vim.loop.cwd())
    end

    local client_id = vim.lsp.start(config)
    if not client_id then
      error("Cold not start lsp client")
    end
    client = vim.lsp.get_client_by_id(client_id)
    new_instance = true
  end

  return client, new_instance
end

---@param full_class string
---@param method string
local go_to = function(full_class, method)
  local server_name = app("options"):get().lsp_server

  local server = servers[server_name]
  if server == nil then
    notify.warn(string.format("No server with name %s found", server_name))
    return
  end

  local client, is_new_instance = get_client(server_name)

  if not client then
    notify.warn("Can't get lsp client")
    return
  end

  return server.go_to(client, is_new_instance, full_class, method)
end

return {
  go_to = go_to,
}
