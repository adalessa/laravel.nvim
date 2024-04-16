---@class NullLsExtension
---@field enable boolean

---@class RouteInfoExtension
---@field enable boolean
---@field position string

---@class LaravelExtensions
---@field null_ls NullLsExtension
---@field route_info RouteInfoExtension
---@field luasnip LuasnipExtension

---@class LuasnipExtension
---@field enable boolean

---@class LaravelOptions
---@field lsp_server string
---@field browser string|nil
---@field register_user_commands boolean
---@field extensions LaravelExtensions
---@field ui LaravelOptionsUI
---@field commands_options table
---@field environments LaravelOptionsEnvironments
---@field user_commands table
---@field resources table
return {
  lsp_server = "phpactor",
  register_user_commands = true,
  extensions = {
    null_ls = {
      enable = true,
    },
    route_info = {
      enable = true,
      position = "right",
    },
    luasnip = {
      enable = true,
    },
  },
  browser = nil,
  ui = require("laravel.config.ui"),
  commands_options = require("laravel.config.command_options"),
  environments = require("laravel.config.environments"),
  user_commands = require("laravel.config.user_commands"),
  resources = require("laravel.config.resources"),
}
