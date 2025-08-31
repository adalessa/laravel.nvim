local app = require("laravel.core.app")

return {
  {
    signature = "model_info:show",
    description = "Show the model info into the model",
    handle = function()
      ---@type laravel.extensions.model_info.lib
      local lib = app:make("laravel.extensions.model_info.lib")
      lib:show(vim.api.nvim_get_current_buf())
    end,
  },
  {
    signature = "model_info:hide",
    description = "Hide the model info into the model",
    handle = function()
      ---@type laravel.extensions.model_info.lib
      local lib = app:make("laravel.extensions.model_info.lib")
      lib:hide(vim.api.nvim_get_current_buf())
    end,
  },
  {
    signature = "model_info:toggle",
    description = "Toggle the model info into the model",
    handle = function()
      ---@type laravel.extensions.model_info.lib
      local lib = app:make("laravel.extensions.model_info.lib")
      lib:toggle(vim.api.nvim_get_current_buf())
    end,
  },
}
