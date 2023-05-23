local application = require "laravel.application"
local Popup = require "nui.popup"
local event = require("nui.utils.autocmd").event

return {
  setup = function()
    vim.api.nvim_create_user_command("LaravelInfo", function()
      -- TODO: show information about the current state of the plugin

      local popup = Popup {
        enter = true,
        focusable = true,
        border = {
          style = "rounded",
        },
        position = "50%",
        size = {
          width = "80%",
          height = "60%",
        },
      }

      -- mount/open the component
      popup:mount()

      -- unmount component when cursor leaves buffer
      popup:on(event.BufLeave, function()
        popup:unmount()
      end)

      vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, vim.fn.split(vim.inspect(application.get_info()), "\n"))
    end, {})
  end,
}
