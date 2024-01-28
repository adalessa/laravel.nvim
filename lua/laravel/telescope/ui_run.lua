local config = require "laravel.config"
local create = require "laravel.resources.create"
local is_resource = require "laravel.resources.is_resource"
local run = require "laravel.run"
local Layout = require "nui.layout"
local Popup = require "nui.popup"
local preview = require "laravel.telescope.preview"

--TODO: can be improved
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
  local command_options = config.options.commands_options[command.name] or {}

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
    }, Popup {
      border = {
        style = "rounded",
        text = {
          top = "Help (<c-c> to cancel)",
          top_align = "center",
        },
      },
    }

  local layout = Layout(
    {
      position = "50%",
      size = {
        width = 80,
        height = "80%",
      },
    },
    -- TODO: set the top line as only 1
    Layout.Box({
      Layout.Box(entry_popup, { size = "15%" }),
      Layout.Box(help_popup, { size = "85%" }),
    }, { dir = "col" })
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
  layout:mount()

  local prompt = "$ artisan " .. command.name .. " "

  vim.api.nvim_buf_add_highlight(entry_popup.bufnr, 0, "String", 0, 0, #prompt)

  vim.fn.prompt_setprompt(entry_popup.bufnr, prompt)
  -- TODO: maybe add highlights
  vim.fn.prompt_setcallback(entry_popup.bufnr, function()
    vim.print "running callback"
    local lines = vim.api.nvim_buf_get_lines(entry_popup.bufnr, 0, 1, false)
    local arguments = lines[1]:sub(string.len(prompt) + 1)
    layout:unmount()

    local args = vim.fn.split(arguments, " ", false)
    table.insert(args, 1, command.name)

    if is_resource(command.name) then
      return create(args)
    end

    run("artisan", args, command_options)
  end)

  vim.cmd [[startinsert]]

  return true
end
