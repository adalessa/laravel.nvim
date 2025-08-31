local app = require("laravel.core.app")

local command = {
  signature = "view:finder",
  description = "Go to view or definition",
}

function command:handle()
  ---@type laravel.services.view_finder
  local finder = app:make("laravel.services.view_finder")
  finder:handle(vim.api.nvim_get_current_buf())
end

return command
