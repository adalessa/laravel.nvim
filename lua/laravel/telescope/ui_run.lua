local Layout = require "nui.layout"
local Popup = require "nui.popup"
local preview = require "laravel.telescope.preview"
local app = require "laravel".app

--- function to scroll a window
---@param popup any id of window
---@param direction string j o k for the direction
local function scroll_fn(popup, direction)
  return function()
    local scroll = vim.api.nvim_win_get_option(popup.winid, "scroll")
    vim.api.nvim_win_call(popup.winid, function()
      vim.cmd("normal! " .. scroll .. direction)
    end)
  end
end

return function(command)
  local entry_popup, help_popup =
    Popup {
      enter = true,
      border = {
        style = "rounded",
        text = {
          top = "Artisan",
          top_align = "center",
        },
      },
      buf_options = {
        buftype = "prompt",
      },
      win_options = {
        winhighlight = "Normal:LaravelPrompt",
      },
    }, Popup {
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
    }

  local layout = Layout(
    {
      position = "50%",
      size = {
        width = "80%",
        height = "90%",
      },
    },
    Layout.Box({
      Layout.Box(entry_popup, { size = 3 }), -- 3 because of borders to be 1 row
      Layout.Box(help_popup, { grow = 1 }),
    }, { dir = "col", relative = "editor" })
  )

  local command_preview = preview.command(command)

  vim.api.nvim_buf_set_lines(help_popup.bufnr, 0, -1, false, command_preview.lines)

  local hl = vim.api.nvim_create_namespace "laravel"
  for _, value in pairs(command_preview.highlights) do
    vim.api.nvim_buf_add_highlight(help_popup.bufnr, hl, value[1], value[2], value[3], value[4])
  end

  entry_popup:map("i", "<c-d>", scroll_fn(help_popup, "j"))
  entry_popup:map("n", "<c-d>", scroll_fn(help_popup, "j"))
  entry_popup:map("i", "<c-u>", scroll_fn(help_popup, "k"))
  entry_popup:map("n", "<c-u>", scroll_fn(help_popup, "k"))
  entry_popup:map("i", "<c-c>", function()
    layout:unmount()
  end)
  entry_popup:map("n", "<c-c>", function()
    layout:unmount()
  end)

  local prompt = "$ artisan " .. command.name .. " "
  vim.fn.prompt_setprompt(entry_popup.bufnr, prompt)
  vim.fn.prompt_setcallback(entry_popup.bufnr, function(input)
    layout:unmount()
    local args = vim.fn.split(input, " ", false)
    table.insert(args, 1, command.name)

    app('runner'):run("artisan", args)
  end)

  layout:mount()
  vim.cmd [[startinsert]]
end
