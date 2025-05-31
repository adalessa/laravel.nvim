local app = require("laravel.core.app")

return {
  {
    signature = "route_info:show",
    description = "Show the route info into the controller",
    handle = function()
      ---@type laravel.extensions.route_info.lib
      local lib = app:make("laravel.extensions.route_info.lib")
      lib:show(vim.api.nvim_get_current_buf())
    end,
  },
  {
    signature = "route_info:hide",
    description = "Hide the route info into the controller",
    handle = function()
      ---@type laravel.extensions.route_info.lib
      local lib = app:make("laravel.extensions.route_info.lib")
      lib:hide(vim.api.nvim_get_current_buf())
    end,
  },
  {
    signature = "route_info:toggle",
    description = "Toggle the route info into the controller",
    handle = function()
      ---@type laravel.extensions.route_info.lib
      local lib = app:make("laravel.extensions.route_info.lib")
      lib:toggle(vim.api.nvim_get_current_buf())
    end,
  },
}
