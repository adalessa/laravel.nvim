local Layout = require("nui.layout")
local Popup = require("nui.popup")
local Input = require("nui.input")
local event = require("nui.utils.autocmd").event

return function(on_submit, on_change)
  local details_popup = Popup({
    border = {
      style = "rounded",
      text = {
        top = "Laravel commands",
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:LaravelHelp",
    },
  })

  local entry_popup = Input({
    focusable = true,
    border = {
      style = "rounded",
      text = {
        top = "Laravel",
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:LaravelPrompt",
    },
  }, {
    prompt = "> ",
    on_submit = on_submit,
    on_change = function(value)
      on_change(value, details_popup)
    end,
  })

  local boxes = {
    Layout.Box(entry_popup, { size = 3 }), -- 3 because of borders to be 1 row
    Layout.Box(details_popup, { grow = 1 }),
  }

  local layout = Layout({
    position = {
      row = "10%",
      col = "50%",
    },
    size = {
      width = "80%",
      height = "35%",
    },
    relative = "editor",
  }, Layout.Box(boxes, { dir = "col" }))

  entry_popup:on(event.BufLeave, function()
    layout:unmount()
  end)

  return layout
end
