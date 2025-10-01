local app = require("laravel.core.app")
local nio = require("nio")

return {
  signature = "view:finder",
  description = "Go to view or definition",
  handle = nio.create(function()
    ---@type laravel.services.view_finder
    local finder = app:make("laravel.services.view_finder")
    finder:handle(vim.api.nvim_get_current_buf())
  end, 1),
}
