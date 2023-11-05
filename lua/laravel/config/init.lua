local M = {}

---@class LaravelOptions
M.defaults = {
  ui = require "laravel.config.ui",
  lsp_server = "phpactor",
  register_user_commands = true,
  bind_telescope = true,
  route_info = {
    enable = true,
    position = "right",
  },
  commands_options = {
    ["queue:restart"] = { watch = true },
    ["tinker"] = { skip_args = true },
    ["docs"] = { ui = "popup", skip_args = true },
  },
  environment = {
    resolver = require "laravel.environment.resolver"(true, true, nil),
    environments = {
      ["local"] = require("laravel.environment.native").setup(),
      ["sail"] = require("laravel.environment.sail").setup(),
      ["docker-compose"] = require("laravel.environment.docker_compose").setup(),
    },
  },
  resources = require "laravel.config.resources",
}

--- @type LaravelOptions
M.options = {}

function M.setup(options)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, options or {})
end

return M
