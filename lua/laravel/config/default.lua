---@class NullLsFeature
---@field enable boolean

---@class RouteInfoFeature
---@field enable boolean
---@field middlewares boolean
---@field method boolean
---@field uri boolean
---@field position string

---@class LaravelFeatures
---@field null_ls NullLsFeature
---@field route_info RouteInfoFeature

---@class LaravelOptions
---@field lsp_server string
---@field register_user_commands boolean
---@field features LaravelFeatures
---@field ui LaravelOptionsUI
---@field commands_options table
---@field environments LaravelOptionsEnvironments
---@field user_commands table
---@field resources table
return {
  lsp_server = "phpactor",
  register_user_commands = true,
  features = {
    null_ls = {
      enable = true,
    },
    route_info = {
      enable = true,
      middlewares = true,
      method = true,
      uri = true,
      position = "right",
    },
  },
  ui = require "laravel.config.ui",
  commands_options = require "laravel.config.command_options",
  environments = require "laravel.config.environments",
  user_commands = require "laravel.config.user_commands",
  resources = require "laravel.config.resources",
}
