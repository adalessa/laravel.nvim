---@class PickersFeature
---@field enable boolean
---@field provider 'telescope'|'ui.select'|'fzf-lua'|'snacks'

---@class LaravelFeatures
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
    completion = { enable = true },
    composer_dev = { enable = true },
    composer_info = { enable = true },
    diagnostic = { enable = true },
    dump_server = { enable = true },
    history = {enable = true },
    model_info = { enable = true },
    override = { enable = true },
    route_info = { enable = true, view = "simple" },
    tinker = { enable = true },
    mcp = { enable = true },
    command_center = { enable = true },
  },
  providers = {
    require("laravel.providers.laravel_provider"),
    require("laravel.providers.pickers_provider"),
    require("laravel.providers.telescope_provider"),
    require("laravel.providers.fzf_lua_provider"),
    require("laravel.providers.ui_select_provider"),
    require("laravel.providers.snacks_provider"),
    require("laravel.providers.user_command_provider"),
    require("laravel.providers.status_provider"),
    require("laravel.providers.actions_provider"),
  },
  user_providers = {},
}
