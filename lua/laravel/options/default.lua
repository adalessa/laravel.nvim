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
  debug_level = vim.log.levels.DEBUG,
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
    dump_server = {
      enable = true,
      ui = {
        tree = {
          enter = true,
          border = {
            style = "rounded",
            text = {
              top = "Dump Server",
            },
          },
          buf_options = {
            modifiable = false,
          },
          win_options = {
            winhighlight = "Normal:LaravelDumpTree,FloatBorder:LaravelDumpTreeBorder",
          },
        },
        preview = {
          border = {
            style = "rounded",
            text = {
              top = "Preview",
              bottom = "Press <Tab> to switch between windows",
            },
          },
          buf_options = {
            modifiable = false,
            filetype = "bash",
          },
          win_options = {
            winhighlight = "Normal:LaravelDumpResult,FloatBorder:LaravelDumpResultBorder",
          },
        },
        layout = {
          position = "50%",
          size = {
            width = "80%",
            height = "60%",
          },
        },
      },
    },
    model_info = { enable = true },
    override = { enable = true },
    route_info = { enable = true, view = "simple" },
    tinker = {
      enable = true,
      ui = {
        editor = {
          enter = true,
          border = {
            style = "rounded",
          },
          buf_options = {},
          win_options = {
            number = true,
            relativenumber = true,
            signcolumn = "yes",
            winhighlight = "Normal:LaravelTinkerCode,FloatBorder:LaravelTinkerCodeBorder",
          },
        },
        result = {
          border = {
            style = "rounded",
          },
          buf_options = {
            modifiable = false,
          },
          win_options = {
            number = false,
            relativenumber = false,
            winhighlight = "Normal:LaravelTinkerResult,FloatBorder:LaravelTinkerResultBorder",
          },
        },
        layout = {
          position = "50%",
          size = {
            width = "80%",
            height = "80%",
          },
          relative = "editor",
        },
      },
    },
    command_center = { enable = true },
  },
  providers = {
    require("laravel.providers.laravel_provider"),
    require("laravel.providers.facades_provider"),
    require("laravel.providers.history_provider"),
    require("laravel.providers.pickers_provider"),
    require("laravel.providers.telescope_provider"),
    require("laravel.providers.fzf_lua_provider"),
    require("laravel.providers.ui_select_provider"),
    require("laravel.providers.snacks_provider"),
    require("laravel.providers.commands_provider"),
    require("laravel.providers.status_provider"),
    require("laravel.providers.actions_provider"),
    require("laravel.providers.extensions_provider"),
    require("laravel.providers.listeners_provider"),
  },
  user_providers = {},
}
