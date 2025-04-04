---@class RouteInfoFeature
---@field enable boolean
---@field view string|table|function module to load or to use

---@class ModelInfoFeature
---@field enable boolean

---@class OverrideFeature
---@field enable boolean

---@class PickersFeature
---@field enable boolean
---@field provider 'telescope'|'ui.select'|'fzf-lua'|'snacks'

---@class LaravelFeatures
---@field route_info RouteInfoFeature
---@field model_info ModelInfoFeature
---@field override OverrideFeature
---@field pickers PickersFeature

---@class LaravelOptions
---@field lsp_server string
---@field features LaravelFeatures
---@field ui LaravelOptionsUI
---@field commands_options table
---@field environments LaravelOptionsEnvironments
---@field user_commands table
---@field resources table
return {
  lsp_server = "phpactor",
  features = {
    pickers = {
      enable = true,
      provider = "telescope",
    },
  },
  ui = require("laravel.options.ui"),
  commands_options = require("laravel.options.command_options"),
  environments = require("laravel.options.environments"),
  user_commands = require("laravel.options.user_commands"),
  resources = require("laravel.options.resources"),
  extensions = {
    composer_info = { enable = true },
    dump_server = { enable = true },
    model_info = { enable = true },
    override = { enable = true },
    route_info = { enable = true, view = "top" },
    tinker = { enable = true },
  },
  providers = {
    require("laravel.providers.laravel_provider"),
    require("laravel.providers.repositories_provider"),
    require("laravel.providers.completion_provider"),
    require("laravel.providers.telescope_provider"),
    require("laravel.providers.fzf_lua_provider"),
    require("laravel.providers.ui_select_provider"),
    require("laravel.providers.snacks_provider"),
    require("laravel.providers.user_command_provider"),
    require("laravel.providers.status_provider"),
    require("laravel.providers.diagnostics_provider"),
    require("laravel.providers.history_provider"),
  },
  user_providers = {},
}
