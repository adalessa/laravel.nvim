local app = require("laravel.core.app")
local nio = require("nio")

return {
  signature = "env:configure:open",
  description = "Open Laravel.nvim configuration for environments",
  handle = nio.create(function()
    vim.cmd("edit " .. app("laravel.core.config").path)
  end, 1),
}
