local Dev = require "laravel.dev"
local defaults = require "laravel._config"
local application = require "laravel.application"
local _autocommands = require "laravel._autocommands"

local log = Dev.log

local M = {}

---Set up laravel plugin
---@param opts laravel.config|nil
function M.setup(opts)
  log.trace "setup(): Setting up..."
  log.trace("setup(): log_key", Dev.get_log_key())

  _autocommands.dir_changed(opts or {})

  local options = vim.tbl_deep_extend("force", defaults, opts or {})

  application.initialize(options)

  if not application.ready() then
    return
  end

  application.warmup()

  -- TODO: remove once 0.9 was general available
  if vim.fn.has "nvim-0.9.0" ~= 1 then
    vim.treesitter.query.get = vim.treesitter.get_query
    vim.treesitter.query.set = vim.treesitter.set_query
  end

  log.debug("setup(): Complete config", options)

  if options.register_user_commands then
    require("laravel.user-commands").setup()
  end

  if options.route_info then
    require("laravel.route_info").register()
  end
end

return M
