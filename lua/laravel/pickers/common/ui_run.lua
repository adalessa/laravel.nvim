local Layout = require("nui.layout")
local Popup = require("nui.popup")
local app = require("laravel").app

---@class UIPopups
---@field entry_popup NuiPopup
---@field help_popup ?NuiPopup

local M = {}

function M.entry_popup()
  return Popup({
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
  })
end

---@param popups UIPopups
function M.ui_run(command, popups)
  local boxes = {
    Layout.Box(popups.entry_popup, { size = 3 }), -- 3 because of borders to be 1 row
  }

  if popups.help_popup then
    table.insert(boxes, Layout.Box(popups.help_popup, { grow = 1 }))
  end

  local layout = Layout({
    position = "50%",
    size = {
      width = "80%",
      height = "90%",
    },
    relative = "editor",
  }, Layout.Box(boxes, { dir = "col" }))

  popups.entry_popup:map("i", "<c-c>", function()
    layout:unmount()
  end)
  popups.entry_popup:map("n", "<c-c>", function()
    layout:unmount()
  end)

  local prompt = "$ artisan " .. command.name .. " "
  vim.fn.prompt_setprompt(popups.entry_popup.bufnr, prompt)
  vim.fn.prompt_setcallback(popups.entry_popup.bufnr, function(input)
    layout:unmount()
    local args = vim.fn.split(input, " ", false)
    table.insert(args, 1, command.name)

    app("runner"):run("artisan", args)
  end)

  layout:mount()
  vim.cmd([[startinsert]])
end

return M
