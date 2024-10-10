local Layout = require("nui.layout")
local Popup = require("nui.popup")
local app = require("laravel").app

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
  local entry_popup = Popup({
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

  local layout = Layout(
    {
      position = "50%",
      size = {
        width = "80%",
        height = "90%",
      },
      relative = "editor",
    },
    Layout.Box({
      Layout.Box(entry_popup, { size = 3 }), -- 3 because of borders to be 1 row
    }, { dir = "col" })
  )

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

    app("runner"):run("artisan", args)
  end)

  layout:mount()
  vim.cmd([[startinsert]])
end
