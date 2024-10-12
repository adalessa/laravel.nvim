local Popup = require("nui.popup")
local preview = require("laravel.pickers.telescope.preview")
local common = require("laravel.pickers.common.ui_run")

--- function to scroll a window
---@param popup any id of window
---@param direction string j o k for the direction
local function scroll_fn(popup, direction)
  return function()
    local scroll = vim.api.nvim_get_option_value("scroll", { win = popup.winid })
    vim.api.nvim_win_call(popup.winid, function()
      vim.cmd("normal! " .. scroll .. direction)
    end)
  end
end

return function(command)
  local entry_popup = common.entry_popup()
  local help_popup = Popup({
    border = {
      style = "rounded",
      text = {
        top = "Help (<c-c> to cancel)",
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:LaravelHelp",
    },
  })

  local command_preview = preview.command(command)

  vim.api.nvim_buf_set_lines(help_popup.bufnr, 0, -1, false, command_preview.lines)

  local hl = vim.api.nvim_create_namespace("laravel")
  for _, value in pairs(command_preview.highlights) do
    vim.api.nvim_buf_add_highlight(help_popup.bufnr, hl, value[1], value[2], value[3], value[4])
  end

  entry_popup:map("i", "<c-d>", scroll_fn(help_popup, "j"))
  entry_popup:map("n", "<c-d>", scroll_fn(help_popup, "j"))
  entry_popup:map("i", "<c-u>", scroll_fn(help_popup, "k"))
  entry_popup:map("n", "<c-u>", scroll_fn(help_popup, "k"))

  common.ui_run(command, { entry_popup = entry_popup, help_popup = help_popup })
end
