local app = require("laravel.core.app")
local nio = require("nio")

return {
  signature = "plugin-logs:open",
  description = "Open Laravel.nvim logs",
  handle = nio.create(function()
    vim.cmd("edit " .. app("laravel.utils.log").path)
  end, 1),
}
