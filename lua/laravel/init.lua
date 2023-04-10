local Dev = require "laravel.dev"

local log = Dev.log

local M = {
  app = nil,
}

---Set up laravel plugin
---@param opts laravel.config|nil
function M.setup(opts)
  -- register command for DirChanged
  -- this should be able to check and update the config
  log.trace "setup(): Setting up..."
  require("laravel.autocommands").dir_changed(opts or {})
  local defaults = require "laravel.defaults"
  local options = vim.tbl_deep_extend("force", defaults, opts or {})

  local app = require "laravel.app"(options)

  if app == nil then
    return
  end

  -- TODO: remove once 0.9 was general available
  if vim.fn.has "nvim-0.9.0" ~= 1 then
    vim.treesitter.query.get = vim.treesitter.get_query
    vim.treesitter.query.set = vim.treesitter.set_query
  end

  ---@var laravel.app
  M.app = app

  log.debug("setup(): Complete config", options)
  log.trace("setup(): log_key", Dev.get_log_key())

  M.app.load_commands()
  M.app.load_routes()

  if options.register_user_commands then
    require("laravel.user-commands").setup()
  end

  if options.route_info then
    require("laravel.route_info").register()
  end
end

return M
